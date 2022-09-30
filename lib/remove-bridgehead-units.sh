#!/bin/bash -e

source lib/functions.sh

if [ $# -eq 0 ]; then
    log "ERROR" "Please provide a Project as argument"
    exit 1
fi

if [ $1 != "ccp" ] && [ $1 != "nngm" ] && [ $1 != "gbn" ]; then
    log "ERROR" "Please provide a supported project like ccp, gbn or nngm"
    exit 1
fi

export PROJECT=$1

#checkRequirements // not needed when uninstalling

log INFO "Removing bridgehead sudoers permissions."

rm -vf /etc/sudoers.d/bridgehead-${PROJECT}

log "INFO" "Stopping system units and removing bridgehead for ${PROJECT} ..."

systemctl disable --now bridgehead@${PROJECT}.service bridgehead-update@${PROJECT}.timer bridgehead-update@${PROJECT}.service

rm -v /etc/systemd/system/{bridgehead\@.service,bridgehead-update\@.timer,bridgehead-update\@.service}

log "INFO" "Successfully removed bridgehead for ${PROJECT} from your system"
