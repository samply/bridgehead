#!/bin/bash
### Note: Currently not complete, needs some features before useable for production

if [ $# -eq 0 ]; then
    echo "Please provide a Project as argument"
    exit 1
fi

if [ $1 != "ccp" ] && [ $1 != "nngm" ] && [ $1 != "gbn" ]; then
    echo "Please provide a supported project like ccp, gbn or nngm"
    exit 1
fi

export project=$1

source lib/functions.sh

if ! lib/prerequisites.sh; then
    log "Validating Prerequisites failed, please fix the occurring error"
    exit 1
fi

source /etc/bridgehead/site.conf

./lib/generate.sh

log "Starting bridgehead"

docker-compose -f $1/docker-compose.yml --env-file /etc/bridgehead/$1.env up -d

log "The bridgehead should be in online in a few seconds"
