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
