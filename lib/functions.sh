#!/bin/bash -e

detectCompose() {
	if [[ "$(docker compose version 2>/dev/null)" == *"Docker Compose version"* ]]; then
		COMPOSE="docker compose"
	else
		COMPOSE="docker-compose"
		# This is intended to fail on startup in the next prereq check.
	fi
}

setupProxy() {
	### Note: As the current data protection concepts do not allow communication via HTTP,
	### we are not setting a proxy for HTTP requests.

	local http="no"
	local https="no"
	if [ $HTTPS_PROXY_URL ]; then
		local proto="$(echo $HTTPS_PROXY_URL | grep :// | sed -e 's,^\(.*://\).*,\1,g')"
		local fqdn="$(echo ${HTTPS_PROXY_URL/$proto/})"
		local hostport=$(echo $HTTPS_PROXY_URL | sed -e "s,$proto,,g" | cut -d/ -f1)
		HTTPS_PROXY_HOST="$(echo $hostport | sed -e 's,:.*,,g')"
		HTTPS_PROXY_PORT="$(echo $hostport | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')"
		if [[ ! -z "$HTTPS_PROXY_USERNAME" && ! -z "$HTTPS_PROXY_PASSWORD" ]]; then
			local proto="$(echo $HTTPS_PROXY_URL | grep :// | sed -e 's,^\(.*://\).*,\1,g')"
			local fqdn="$(echo ${HTTPS_PROXY_URL/$proto/})"
			HTTPS_PROXY_FULL_URL="$(echo $proto$HTTPS_PROXY_USERNAME:$HTTPS_PROXY_PASSWORD@$fqdn)"
			https="authenticated"
		else
			HTTPS_PROXY_FULL_URL=$HTTPS_PROXY_URL
			https="unauthenticated"
		fi
	fi

	log INFO "Configuring proxy servers: $http http proxy (we're not supporting unencrypted comms), $https https proxy"
	export HTTPS_PROXY_HOST HTTPS_PROXY_PORT HTTPS_PROXY_FULL_URL
}

exitIfNotRoot() {
  if [ "$EUID" -ne 0 ]; then
    log "ERROR" "Please run as root"
    fail_and_report 1 "Please run as root"
  fi
}

checkOwner(){
  COUNT=$(find $1 ! -user $2 |wc -l)
  if [ $COUNT -gt 0 ]; then
    log ERROR "$COUNT files in $1 are not owned by user $2. Run find $1 ! -user $2 to see them, chown -R $2 $1 to correct this issue."
    return 1
  fi
  return 0
}

printUsage() {
	echo "Usage: bridgehead start|stop|logs|docker-logs|is-running|update|check|install|uninstall|adduser|enroll PROJECTNAME"
	echo "PROJECTNAME should be one of ccp|bbmri|cce|itcc|kr|dhki|nngm"
}

checkRequirements() {
	if ! lib/prerequisites.sh $@; then
		log "ERROR" "Validating Prerequisites failed, please fix the error(s) above this line."
		fail_and_report 1 "Validating prerequisites failed."
	else
		return 0
	fi
}

fetchVarsFromVault() {
	[ -e /etc/bridgehead/vault.conf ] && source /etc/bridgehead/vault.conf

	if [ -z "$BW_MASTERPASS" ] || [ -z "$BW_CLIENTID" ] || [ -z "$BW_CLIENTSECRET" ]; then
		log "ERROR" "Please supply correct credentials in /etc/bridgehead/vault.conf."
		return 1
	fi

	set +e

	PASS=$(BW_MASTERPASS="$BW_MASTERPASS" BW_CLIENTID="$BW_CLIENTID" BW_CLIENTSECRET="$BW_CLIENTSECRET" docker run --rm -e BW_MASTERPASS -e BW_CLIENTID -e BW_CLIENTSECRET -e http_proxy docker.verbis.dkfz.de/cache/samply/bridgehead-vaultfetcher:latest $@)
	RET=$?

	if [ $RET -ne 0 ]; then
		echo "Code: $RET"
		echo $PASS
		return $RET
	fi

	eval $(echo -e "$PASS" | sed 's/\r//g')

	set -e

	return 0
}

fetchVarsFromVaultByFile() {
	VARS_TO_FETCH=""

	for line in $(cat $@); do
		if [[ $line =~ .*=[\"]*\<VAULT\>[\"]*.* ]]; then
			VARS_TO_FETCH+="$(echo -n $line | sed 's/=.*//') "
		fi
	done

	if [ -z "$VARS_TO_FETCH" ]; then
		return 0
	fi

	log INFO "Fetching $(echo $VARS_TO_FETCH | wc -w) secrets from Vault ..."

	fetchVarsFromVault $VARS_TO_FETCH

	return 0
}

assertVarsNotEmpty() {
	MISSING_VARS=""

	for VAR in $@; do
		if [ -z "${!VAR}" ]; then
			MISSING_VARS+="$VAR "
		fi
	done

	if [ -n "$MISSING_VARS" ]; then
		log "ERROR" "Mandatory variables not defined: $MISSING_VARS"
		return 1
	fi

	return 0
}

fixPermissions() {
	CHOWN=$(which chown)
	sudo $CHOWN -R bridgehead /etc/bridgehead /srv/docker/bridgehead
}

source lib/monitoring.sh

report_error() {
	CODE=$1
	shift
	log ERROR "$@"
	hc_send $CODE "$@"
}

fail_and_report() {
	report_error $@
	exit $1
}

setHostname() {
	if [ -z "$HOST" ]; then
		export HOST=$(hostname -f | tr "[:upper:]" "[:lower:]")
		log DEBUG "Using auto-detected hostname $HOST."
	fi
}

# This function optimizes the usage of memory through blaze, according to the official performance tuning guide:
#   https://github.com/samply/blaze/blob/master/docs/tuning-guide.md
# Short summary of the adjustments made:
# - set blaze memory cap to a quarter of the system memory
# - set db block cache size to a quarter of the system memory
# - limit resource count allowed in blaze to 1,25M per 4GB available system memory
optimizeBlazeMemoryUsage() {
	if [ -z "$BLAZE_MEMORY_CAP" ]; then
	   system_memory_in_mb=$(LC_ALL=C free -m | grep 'Mem:' | awk '{print $2}');
	   export BLAZE_MEMORY_CAP=$(($system_memory_in_mb/4));
	fi
	if [ -z "$BLAZE_RESOURCE_CACHE_CAP" ]; then
		available_system_memory_chunks=$((BLAZE_MEMORY_CAP / 1000))
		if [ $available_system_memory_chunks -eq 0 ]; then
			log WARN "Only ${BLAZE_MEMORY_CAP} system memory available for Blaze. If your Blaze stores more than 128000 fhir ressources it will run significally slower."
			export BLAZE_RESOURCE_CACHE_CAP=128000;
			export BLAZE_CQL_CACHE_CAP=32;
		else
			export BLAZE_RESOURCE_CACHE_CAP=$((available_system_memory_chunks * 312500))
			export BLAZE_CQL_CACHE_CAP=$((($system_memory_in_mb/4)/16));
		fi
	fi
}

# Takes 1) The Backup Directory Path 2) The name of the Service to be backuped
# Creates 3 Backups: 1) For the past seven days 2) For the current month and 3) for each calendar week
createEncryptedPostgresBackup(){
  docker exec "$2" bash -c 'pg_dump -U $POSTGRES_USER $POSTGRES_DB --format=p --no-owner --no-privileges' | \
      # TODO: Encrypt using /etc/bridgehead/pki/${SITE_ID}.priv.pem | \
      tee "$1/$2/$(date +Last-%A).sql" | \
      tee "$1/$2/$(date +%Y-%m).sql" > \
      "$1/$2/$(date +%Y-KW%V).sql"
}


# from: https://gist.github.com/sj26/88e1c6584397bb7c13bd11108a579746
# ex. use: retry 5 /bin/false
function retry {
  local retries=$1
  shift

  local count=0
  until "$@"; do
    exit=$?
    wait=$((2 ** $count))
    count=$(($count + 1))
    if [ $count -lt $retries ]; then
      echo "Retry $count/$retries exited with code $exit, retrying in $wait seconds..."
      sleep $wait
    else
      echo "Retry $count/$retries exited with code $exit, giving up."
      return $exit
    fi
  done
  return 0
}

function bk_is_running {
	detectCompose
	RUNNING="$($COMPOSE -p $PROJECT -f minimal/docker-compose.yml -f ./$PROJECT/docker-compose.yml $OVERRIDE ps -q)"
	NUMBEROFRUNNING=$(echo "$RUNNING" | wc -l)
	if [ $NUMBEROFRUNNING -ge 2 ]; then
		return 0
	else
		return 1
	fi
}

function do_enroll_inner {
	PARAMS=""
	
	MANUAL_PROXY_ID="${1:-$PROXY_ID}"
	if [ -z "$MANUAL_PROXY_ID" ]; then
		log ERROR "No Proxy ID set"
		exit 1
	else
		log INFO "Enrolling Beam Proxy Id $MANUAL_PROXY_ID"
	fi

	SUPPORT_EMAIL="${2:-$SUPPORT_EMAIL}"
	if [ -n "$SUPPORT_EMAIL" ]; then
		PARAMS+="--admin-email $SUPPORT_EMAIL"
	fi

	docker run --rm -v /etc/bridgehead/pki:/etc/bridgehead/pki docker.verbis.dkfz.de/cache/samply/beam-enroll:latest --output-file $PRIVATEKEYFILENAME --proxy-id $MANUAL_PROXY_ID $PARAMS
	chmod 600 $PRIVATEKEYFILENAME
}

function do_enroll {
	do_enroll_inner $@
}

add_basic_auth_user() {
   USER="${1}"
   PASSWORD="${2}"
   NAME="${3}"
   PROJECT="${4}"
   FILE="/etc/bridgehead/${PROJECT}.local.conf"
   ENCRY_CREDENTIALS="$(docker run --rm docker.verbis.dkfz.de/cache/httpd:alpine htpasswd -nb $USER $PASSWORD  | tr -d '\n' | tr -d '\r')"
   if [ -f $FILE ] && grep -R -q "$NAME=" $FILE # if a specific basic auth user already exists:
   then
     sed -i "/$NAME/ s|='|='$ENCRY_CREDENTIALS,|" $FILE
   else
     echo -e "\n## Basic Authentication Credentials for:\n$NAME='$ENCRY_CREDENTIALS'" >> $FILE;
   fi
 	log DEBUG "Saving clear text credentials in $FILE. If wanted, delete them manually."
   sed -i "/^$NAME/ s|$|\n# User: $USER\n# Password: $PASSWORD|" $FILE
}

OIDC_PUBLIC_REDIRECT_URLS=${OIDC_PUBLIC_REDIRECT_URLS:-""}
OIDC_PRIVATE_REDIRECT_URLS=${OIDC_PRIVATE_REDIRECT_URLS:-""}

# Add a redirect url to the public oidc client of the bridgehead
function add_public_oidc_redirect_url() {
    if [[ $OIDC_PUBLIC_REDIRECT_URLS == "" ]]; then
        OIDC_PUBLIC_REDIRECT_URLS+="$(generate_redirect_urls $1)"
    else 
        OIDC_PUBLIC_REDIRECT_URLS+=",$(generate_redirect_urls $1)"
    fi
}

# Add a redirect url to the private oidc client of the bridgehead
function add_private_oidc_redirect_url() {
    if [[ $OIDC_PRIVATE_REDIRECT_URLS == "" ]]; then
        OIDC_PRIVATE_REDIRECT_URLS+="$(generate_redirect_urls $1)"
    else 
        OIDC_PRIVATE_REDIRECT_URLS+=",$(generate_redirect_urls $1)"
    fi
}

function sync_secrets() {
    local delimiter=$'\x1E'
    local secret_sync_args=""
    if [[ $OIDC_PRIVATE_REDIRECT_URLS != "" ]]; then
        secret_sync_args="OIDC:OIDC_CLIENT_SECRET:private;$OIDC_PRIVATE_REDIRECT_URLS"
    fi
    if [[ $OIDC_PUBLIC_REDIRECT_URLS != "" ]]; then
        if [[ $secret_sync_args == "" ]]; then
            secret_sync_args="OIDC:OIDC_PUBLIC:public;$OIDC_PUBLIC_REDIRECT_URLS"
        else
            secret_sync_args+="${delimiter}OIDC:OIDC_PUBLIC:public;$OIDC_PUBLIC_REDIRECT_URLS"
        fi
    fi
    if [[ $secret_sync_args == "" ]]; then
        return
    fi

    if [ "$PROJECT" == "bbmri" ]; then
        # If the project is BBMRI, use the BBMRI-ERIC broker and not the GBN broker
        proxy_id=$ERIC_PROXY_ID
        broker_url=$ERIC_BROKER_URL
        broker_id=$ERIC_BROKER_ID
        root_crt_file="/srv/docker/bridgehead/bbmri/modules/${ERIC_ROOT_CERT}.root.crt.pem"
    else
        proxy_id=$PROXY_ID
        broker_url=$BROKER_URL
        broker_id=$BROKER_ID
        root_crt_file="/srv/docker/bridgehead/$PROJECT/root.crt.pem"
    fi

    mkdir -p /var/cache/bridgehead/secrets/ || fail_and_report 1 "Failed to create '/var/cache/bridgehead/secrets/'. Please run sudo './bridgehead install $PROJECT' again."
    touch /var/cache/bridgehead/secrets/oidc
    docker run --rm \
        -v /var/cache/bridgehead/secrets/oidc:/usr/local/cache \
        -v $PRIVATEKEYFILENAME:/run/secrets/privkey.pem:ro \
        -v $root_crt_file:/run/secrets/root.crt.pem:ro \
        -v /etc/bridgehead/trusted-ca-certs:/conf/trusted-ca-certs:ro \
        -e TLS_CA_CERTIFICATES_DIR=/conf/trusted-ca-certs \
        -e NO_PROXY=localhost,127.0.0.1 \
        -e ALL_PROXY=$HTTPS_PROXY_FULL_URL \
        -e PROXY_ID=$proxy_id \
        -e BROKER_URL=$broker_url \
        -e OIDC_PROVIDER=secret-sync-central.central-secret-sync.$broker_id \
        -e SECRET_DEFINITIONS=$secret_sync_args \
        docker.verbis.dkfz.de/cache/samply/secret-sync-local:latest

    set -a # Export variables as environment variables
    source /var/cache/bridgehead/secrets/oidc
    set +a # Export variables in the regular way
}

# Map a GitLab URL to the prefix recognized by Secret Sync
function secret_sync_gitlab_instance() {
    case "$1" in
        *git.verbis.dkfz.de*) echo verbis;;
        *gitlab.bbmri-eric.eu*) echo bbmri;;
        *) return 1;;
    esac
}

# Use Secret Sync to validate the GitLab token in /var/cache/bridgehead/secrets/gitlab-token.
# If it is missing or expired, Secret Sync will create a new token and write it to the file.
# The git credential helper reads the token from the file during git pull.
function secret_sync_fetch_gitlab_token() {
    local gitlab=$1 proxy_id=$2 broker_url=$3 broker_id=$4 privkey_file=$5 root_crt_file=$6
    if [ ! -f "$privkey_file" ] || [ ! -f "$root_crt_file" ]; then
        log "WARN" "Not running Secret Sync because $privkey_file or $root_crt_file is missing"
        return 1
    fi
    local trusted_ca_args=()
    if [ -d /etc/bridgehead/trusted-ca-certs ]; then
        trusted_ca_args=(-v /etc/bridgehead/trusted-ca-certs:/conf/trusted-ca-certs:ro -e TLS_CA_CERTIFICATES_DIR=/conf/trusted-ca-certs)
    fi
    mkdir -p /var/cache/bridgehead/secrets
    log "INFO" "Running Secret Sync for the GitLab token (gitlab=$gitlab)"
    docker pull docker.verbis.dkfz.de/cache/samply/secret-sync-local:latest # make sure we have the latest image
    docker run --rm \
        -v $privkey_file:/run/secrets/privkey.pem:ro \
        -v $root_crt_file:/run/secrets/root.crt.pem:ro \
        "${trusted_ca_args[@]}" \
        -v /var/cache/bridgehead/secrets:/secret-sync/ \
        -e CACHE_PATH=/secret-sync/gitlab-token \
        -e NO_PROXY=localhost,127.0.0.1 \
        -e ALL_PROXY=$HTTPS_PROXY_FULL_URL \
        -e PROXY_ID=$proxy_id \
        -e BROKER_URL=$broker_url \
        -e GITLAB_PROJECT_ACCESS_TOKEN_PROVIDER=secret-sync-central.central-secret-sync.$broker_id \
        -e SECRET_DEFINITIONS=GitLabProjectAccessToken:BRIDGEHEAD_CONFIG_REPO_TOKEN:$gitlab \
        docker.verbis.dkfz.de/cache/samply/secret-sync-local:latest
}

function secret_sync_gitlab_token() {
    if [[ "$PROJECT" != "ccp" && "$PROJECT" != "bbmri" && "$PROJECT" != "cce" ]] && [ -z "$(git -C /etc/bridgehead config credential.helper)" ]; then
        log "INFO" "Not running Secret Sync for project $PROJECT"
        return
    fi
    local gitlab
    if ! gitlab=$(secret_sync_gitlab_instance "$(git -C /etc/bridgehead remote get-url origin)"); then
        log "WARN" "Not running Secret Sync because the git repository /etc/bridgehead has unknown origin"
        return
    fi

    if [ "$PROJECT" == "bbmri" ]; then
        # If the project is BBMRI, use the BBMRI-ERIC broker and not the GBN broker
        proxy_id=$ERIC_PROXY_ID
        broker_url=$ERIC_BROKER_URL
        broker_id=$ERIC_BROKER_ID
        root_crt_file="/srv/docker/bridgehead/bbmri/modules/${ERIC_ROOT_CERT}.root.crt.pem"
    else
        proxy_id=$PROXY_ID
        broker_url=$BROKER_URL
        broker_id=$BROKER_ID
        root_crt_file="/srv/docker/bridgehead/$PROJECT/root.crt.pem"
    fi

    if secret_sync_fetch_gitlab_token "$gitlab" "$proxy_id" "$broker_url" "$broker_id" "$PRIVATEKEYFILENAME" "$root_crt_file"; then
        log "INFO" "Secret Sync was successful"
        # In the past we used to hardcode tokens into the repository URL. We have to remove those now for the git credential helper to become effective.
        CLEAN_REPO="$(git -C /etc/bridgehead remote get-url origin | sed -E 's|https://[^@]+@|https://|')"
        git -C /etc/bridgehead remote set-url origin "$CLEAN_REPO"
        # Set the git credential helper
        git -C /etc/bridgehead config credential.helper /srv/docker/bridgehead/lib/gitlab-token-helper.sh
    else
        log "WARN" "Secret Sync failed"
    fi

    # In the past the git credential helper was also set for /srv/docker/bridgehead but never used.
    # Let's remove it to avoid confusion. This line can be removed at some point the future when we
    # believe that it was removed on all/most production servers.
    git -C /srv/docker/bridgehead config --unset credential.helper
}

function bootstrap_site_configuration() {
    local site=$1 enrollment_code=$2 repository_url=$3
    local SITE_ID=$site BROKER_ID="" BROKER_URL="" PROXY_ID="" PRIVATEKEYFILENAME=""
    local HTTPS_PROXY_FULL_URL=${HTTPS_PROXY_FULL_URL:-${https_proxy:-${HTTPS_PROXY:-}}}
    eval "$(grep -E '^(BROKER_ID|BROKER_URL|PROXY_ID|PRIVATEKEYFILENAME)=' "$PROJECT/vars")"
    if [ -z "$BROKER_ID" ]; then
        log "ERROR" "Project $PROJECT has no Samply.Beam broker to enroll with."
        return 1
    fi
    local gitlab
    if ! gitlab=$(secret_sync_gitlab_instance "$repository_url"); then
        log "ERROR" "Secret Sync does not support the GitLab server of $repository_url."
        return 1
    fi

    local enroll_dir
    enroll_dir=$(mktemp -d /run/bridgehead-enrollment.XXXXXX)
    local key_file="$enroll_dir/$SITE_ID.priv.pem"
    log "INFO" "Enrolling Beam Proxy Id $PROXY_ID"
    if ! docker run --rm -v "$enroll_dir:/pki" docker.verbis.dkfz.de/cache/samply/beam-enroll:latest --output-file "/pki/$SITE_ID.priv.pem" --proxy-id "$PROXY_ID" > "$enroll_dir/enroll.out"; then
        log "ERROR" "Unable to generate the private key for $PROXY_ID."
        rm -rf "$enroll_dir"
        return 1
    fi
    local csr
    csr=$(sed -n '/BEGIN CERTIFICATE REQUEST/,/END CERTIFICATE REQUEST/p' "$enroll_dir/enroll.out")
    local response
    response=$(curl -sS --data-urlencode "csr=$csr" --data-urlencode "token=$enrollment_code" "$BROKER_URL/csr" 2>&1)
    if [[ "$response" != *"Successfully registered CSR"* ]]; then
        log "ERROR" "$BROKER_URL did not accept the certificate request with your one-time enrollment code: $(echo "$response" | sed -e 's/<[^>]*>//g' | tr -s '[:space:]' ' ' | head -c 300)"
        rm -rf "$enroll_dir"
        return 1
    fi

    local answer
    until retry 3 secret_sync_fetch_gitlab_token "$gitlab" "$PROXY_ID" "$BROKER_URL" "$BROKER_ID" "$key_file" "/srv/docker/bridgehead/$PROJECT/root.crt.pem" \
        && git -c credential.helper=/srv/docker/bridgehead/lib/gitlab-token-helper.sh clone "$repository_url" /etc/bridgehead; do
        log "ERROR" "Unable to download $repository_url."
        read -r -p "Fix the cause and retry? If you don't, you will need a new one-time enrollment code. [Y/n] " answer || answer=n
        if [[ "$answer" == [Nn]* ]]; then
            rm -rf "$enroll_dir"
            return 1
        fi
    done
    local configured_site_id
    configured_site_id=$(grep -m1 -E '^SITE_ID=' "/etc/bridgehead/$PROJECT.conf" | cut -d= -f2- | tr -d "\"'")
    if [ "$configured_site_id" != "$SITE_ID" ]; then
        log "ERROR" "Your configuration repository is for site '$configured_site_id', but you entered '$SITE_ID'. Ask for a one-time enrollment code for '$configured_site_id' and run the installation again."
        rm -rf /etc/bridgehead "$enroll_dir"
        return 1
    fi
    git -C /etc/bridgehead config credential.helper /srv/docker/bridgehead/lib/gitlab-token-helper.sh
    mkdir -p "$(dirname "$PRIVATEKEYFILENAME")"
    mv "$key_file" "$PRIVATEKEYFILENAME"
    chmod 600 "$PRIVATEKEYFILENAME"
    rm -rf "$enroll_dir"
}

capitalize_first_letter() {
    input="$1"
    capitalized="$(tr '[:lower:]' '[:upper:]' <<< ${input:0:1})${input:1}"
    echo "$capitalized"
}

# Generate a string of ',' separated string of redirect urls relative to $HOST.
# $1 will be appended to the url
# If the host looks like dev-jan.inet.dkfz-heidelberg.de it will generate urls with dev-jan and the original $HOST as url Authorities
function generate_redirect_urls(){
    local redirect_urls="https://${HOST}$1"
    local host_without_proxy="$(echo "$HOST" | cut -d '.' -f1)"
    # Only append second url if its different and the host is not an ip address
    if [[ "$HOST" != "$host_without_proxy" && ! "$HOST" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        redirect_urls+=",https://$host_without_proxy$1"
    fi
    echo "$redirect_urls"
}

# This password contains at least one special char, a random number and a random upper and lower case letter
generate_password(){
  local seed_text="$1"
  local seed_num=$(awk 'BEGIN{FS=""} NR==1{print $10}' /etc/bridgehead/pki/${SITE_ID}.priv.pem | od -An -tuC)
  local nums="1234567890"
  local n=$(echo "$seed_num" | awk '{print $1 % 10}')
  local random_digit=${nums:$n:1}
  local n=$(echo "$seed_num" | awk '{print $1 % 26}')
  local upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  local lower="abcdefghijklmnopqrstuvwxyz"
  local random_upper=${upper:$n:1}
  local random_lower=${lower:$n:1}
  local n=$(echo "$seed_num" | awk '{print $1 % 8}')
  local special='@#$%^&+='
  local random_special=${special:$n:1}

  local combined_text="This is a salt string to generate one consistent password for ${seed_text}. It is not required to be secret."
  local main_password=$(echo "${combined_text}" | sha1sum | openssl pkeyutl -sign -inkey "/etc/bridgehead/pki/${SITE_ID}.priv.pem" 2> /dev/null | base64 | head -c 26 | sed 's/\//A/g')

  echo "${main_password}${random_digit}${random_upper}${random_lower}${random_special}"
}

# This password only contains alphanumeric characters
generate_simple_password(){
  local seed_text="$1"
  local combined_text="This is a salt string to generate one consistent password for ${seed_text}. It is not required to be secret."
  echo "${combined_text}" | sha1sum | openssl pkeyutl -sign -inkey "/etc/bridgehead/pki/${SITE_ID}.priv.pem" 2> /dev/null | base64 | head -c 26 | sed 's/[+\/]/A/g'
}
