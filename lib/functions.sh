#!/bin/bash -e

source lib/log.sh

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
	echo "Usage: bridgehead start|stop|update|install|uninstall|enroll PROJECTNAME"
	echo "PROJECTNAME should be one of ccp|nngm|gbn"
}

checkRequirements() {
	if ! lib/prerequisites.sh; then
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

fail_and_report() {
	log ERROR "$2"
	hc_send $1 "$2"
	exit $1
}

##Setting Network properties
export HOSTIP=$(MSYS_NO_PATHCONV=1 docker run --rm --add-host=host.docker.internal:host-gateway ubuntu cat /etc/hosts | grep 'host.docker.internal' | awk '{print $1}');
export HOST=$(hostname)
export PRODUCTION="false";
if [ "$(git branch --show-current)" == "main" ]; then
	export PRODUCTION="true";
fi
