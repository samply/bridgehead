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
	echo "Usage: bridgehead start|stop|is-running|update|install|uninstall|adduser|enroll PROJECTNAME"
	echo "PROJECTNAME should be one of ccp|bbmri"
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

function clone_repo_if_nonexistent() {
    local repo_url="$1"  # First argument: Repository URL
    local target_dir="$2"  # Second argument: Target directory
    local branch_name="$3"  # Third argument: Branch name

    echo Repo directory: $target_dir

    # Check if the target directory exists
    if [ ! -d "$target_dir" ]; then
        echo "Directory '$target_dir' does not exist. Cloning the repository..."
        # Clone the repository
        git clone "$repo_url" "$target_dir"
    fi

    # Change to the cloned directory
    cd "$target_dir"

    # Checkout the specified branch
    git checkout "$branch_name"
    echo "Checked out branch '$branch_name'."

    cd -
}

function clone_transfair_if_nonexistent() {
    local base_dir="$1"

    clone_repo_if_nonexistent https://github.com/samply/transFAIR.git $base_dir/transfair main_ecdc_amt_prototype
}

function clone_focus_if_nonexistent() {
    local base_dir="$1"

    clone_repo_if_nonexistent https://github.com/samply/focus.git $base_dir/focus ehds2
}


function build_transfair() {
    local base_dir="$1"

    # We only take the touble to build transfair if:
    #
    # 1. There is no data lock file (which means that no ETL has yet been run) and
    # 2. There is data available.
    if [ -f ../ecdc/data/*.[cC][sS][vV] ] && [ ! -f ../ecdc/data/lock ]; then
        cd $base_dir/transfair
        docker build --progress=plain -t samply/transfair --no-cache .
        cd -
    fi
}

function build_focus() {
    local base_dir="$1"

    cd $base_dir/focus
    docker build --progress=plain -f DockerfileWithBuild -t samply/focus --no-cache .
    cd -
}

