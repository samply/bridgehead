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
	echo "Usage: bridgehead start|stop|logs|docker-logs|is-running|update|install|uninstall|adduser|enroll|gitCredentials PROJECTNAME"
	echo "PROJECTNAME should be one of ccp|bbmri|cce|itcc|kr|dhki"
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
		if [ -z "${VAR+x}" ] || [ -z "$VAR" ]; then
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
    mkdir -p /var/cache/bridgehead/secrets/ || fail_and_report 1 "Failed to create '/var/cache/bridgehead/secrets/'. Please run sudo './bridgehead install $PROJECT' again."
    touch /var/cache/bridgehead/secrets/oidc
    docker run --rm \
        -v /var/cache/bridgehead/secrets/oidc:/usr/local/cache \
        -v $PRIVATEKEYFILENAME:/run/secrets/privkey.pem:ro \
        -v /srv/docker/bridgehead/$PROJECT/root.crt.pem:/run/secrets/root.crt.pem:ro \
        -v /etc/bridgehead/trusted-ca-certs:/conf/trusted-ca-certs:ro \
        -e TLS_CA_CERTIFICATES_DIR=/conf/trusted-ca-certs \
        -e NO_PROXY=localhost,127.0.0.1 \
        -e ALL_PROXY=$HTTPS_PROXY_FULL_URL \
        -e PROXY_ID=$PROXY_ID \
        -e BROKER_URL=$BROKER_URL \
        -e OIDC_PROVIDER=secret-sync-central.oidc-client-enrollment.$BROKER_ID \
        -e SECRET_DEFINITIONS=$secret_sync_args \
        docker.verbis.dkfz.de/cache/samply/secret-sync-local:latest

    set -a # Export variables as environment variables
    source /var/cache/bridgehead/secrets/*
    set +a # Export variables in the regular way
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

docker_jq() {
    docker run --rm -i docker.verbis.dkfz.de/cache/jqlang/jq:latest "$@"
}
