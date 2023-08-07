#!/bin/bash -e

detectCompose() {
	if [[ "$(docker compose version 2>/dev/null)" == *"Docker Compose version"* ]]; then
		COMPOSE="docker compose"
	else
		COMPOSE="docker-compose"
		# This is intended to fail on startup in the next prereq check.
	fi
}

getLdmPassword() {
	if [ -n "$LDM_PASSWORD" ]; then
		docker run --rm docker.verbis.dkfz.de/cache/httpd:alpine htpasswd -nb $PROJECT $LDM_PASSWORD | tr -d '\n' | tr -d '\r'
	else
		echo -n ""
	fi
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
	echo "Usage: bridgehead start|stop|is-running|update|install|uninstall|enroll PROJECTNAME"
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

	PASS=$(BW_MASTERPASS="$BW_MASTERPASS" BW_CLIENTID="$BW_CLIENTID" BW_CLIENTSECRET="$BW_CLIENTSECRET" docker run --rm -e BW_MASTERPASS -e BW_CLIENTID -e BW_CLIENTSECRET -e http_proxy samply/bridgehead-vaultfetcher $@)
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

	docker run --rm -ti -v /etc/bridgehead/pki:/etc/bridgehead/pki samply/beam-enroll:latest --output-file $PRIVATEKEYFILENAME --proxy-id $MANUAL_PROXY_ID $PARAMS
	chmod 600 $PRIVATEKEYFILENAME
}

function do_enroll {
	do_enroll_inner $@
}