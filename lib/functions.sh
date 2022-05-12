#!/bin/bash -e

exitIfNotRoot() {
  if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
  fi
}

log() {
  echo "$(date +'%Y-%m-%d %T')" "$1:" "$2"
}

printUsage() {
	echo "Usage: bridgehead start|stop|update|install|uninstall PROJECTNAME"
}

checkRequirements() {
	if ! lib/prerequisites.sh; then
		log ERROR "Validating Prerequisites failed, please fix the error(s) above this line."
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

	eval $(docker run --rm -ti -e BW_MASTERPASS -e BW_CLIENTID -e BW_CLIENTSECRET bwcli $VARS_TO_FETCH | sed 's/\r//g')

	return 0
}
