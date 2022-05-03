#!/bin/bash -e

source lib/functions.sh

if [ $# -eq 0 ]; then
    echo "Please provide a Project as argument"
    exit 1
fi

if [ $1 != "ccp" ] && [$1 != "nngm"] && [ $1 != "gbn" ]; then
    echo "Please provide a supported project like ccp, gbn or nngm"
    exit 1
fi

log "Stopping bridgehead"

# TODO: Check $1 for proper values
docker-compose -f $1/docker-compose.yml --env-file /etc/bridgehead-config/$1.env down
