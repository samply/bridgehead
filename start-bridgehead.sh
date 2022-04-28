#!/bin/bash
### Note: Currently not complete, needs some features before useable for production

if [ $# -eq 0 ]; then
    echo "No arguments provided"
    exit 1
fi

source lib/functions.sh

if ! lib/prerequisites.sh; then
    log "Prerequisites failed, exiting"
    exit
fi

./lib/generate.sh

log "Starting bridgehead"

# TODO: Check $1 for proper values
docker-compose -f $1/docker-compose.yml --env-file bridgehead-config/$1.env up -d

log "The bridgehead should be in online in a few seconds"
