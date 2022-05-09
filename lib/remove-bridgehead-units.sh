#!/bin/bash -e

source lib/functions.sh

if [ $# -eq 0 ]; then
    log "Please provide a Project as argument"
    exit 1
fi

if [ $1 != "ccp" ] && [ $1 != "nngm" ] && [ $1 != "gbn" ]; then
    log "Please provide a supported project like ccp, gbn or nngm"
    exit 1
fi

export project=$1

if ! ./lib/prerequisites.sh; then
    log "Prerequisites failed, exiting"
    exit 1
fi

log "Stopping systemd services and removing bridgehead ..."

systemctl disable --now bridgehead@${project}.service bridgehead-update@${project}.timer bridgehead-update@${project}.service

rm -v /etc/systemd/system/{bridgehead\@.service,bridgehead-update\@.timer,bridgehead-update\@.service}
