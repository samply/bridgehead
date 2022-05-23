#!/bin/bash -e

exitIfNotRoot() {
  if [ "$EUID" -ne 0 ]; then
    log "ERROR" "Please run as root"
    exit 1
  fi
}

log() {
  echo -e "$(date +'%Y-%m-%d %T')" "$1:" "$2"
}

printUsage() {
	echo "Usage: bridgehead start|stop|update|install|uninstall PROJECTNAME"
	echo "PROJECTNAME should be one of ccp|nngm|gbn"
}

checkRequirements() {
	if ! lib/prerequisites.sh; then
		log "ERROR" "Validating Prerequisites failed, please fix the error(s) above this line."
		exit 1
	else
		return 0
	fi
}

fetchVarsFromVault() {
	VARS_TO_FETCH=""

	for line in $(cat $@); do
		if [[ $line =~ .*=\<VAULT\>.* ]]; then
			VARS_TO_FETCH+="$(echo -n $line | sed 's/=.*//') "
		fi
	done

	if [ -z "$VARS_TO_FETCH" ]; then
		return 0
	fi

	log "INFO" "Fetching secrets from vault ..."

	[ -e /etc/bridgehead/vault.conf ] && source /etc/bridgehead/vault.conf

	if [ -z "$BW_MASTERPASS" ] || [ -z "$BW_CLIENTID" ] || [ -z "$BW_CLIENTSECRET" ]; then
		log "ERROR" "Please supply correct credentials in /etc/bridgehead/vault.conf."
		return 1
	fi

	set +e

	PASS=$(BW_MASTERPASS="$BW_MASTERPASS" BW_CLIENTID="$BW_CLIENTID" BW_CLIENTSECRET="$BW_CLIENTSECRET" docker run --rm -e BW_MASTERPASS -e BW_CLIENTID -e BW_CLIENTSECRET -e http_proxy samply/bridgehead-vaultfetcher $VARS_TO_FETCH)
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

##Setting Network properties
export HOSTIP=$(MSYS_NO_PATHCONV=1 docker run --rm --add-host=host.docker.internal:host-gateway ubuntu cat /etc/hosts | grep 'host.docker.internal' | awk '{print $1}');
export HOST=$(hostname)
export PRODUCTION="false";
if [ "$(git branch --show-current)" == "main" ]; then
	export PRODUCTION="true";
fi
