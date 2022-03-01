#!/bin/bash
### Note: Currently not complete, needs some features before useable for production

source lib/functions.sh

if ! lib/prerequisites.sh; then
    log "Prerequisites failed, exiting"
    exit
fi

log "Starting bridgehead"

# TODO: Check $1 for proper values
docker-compose -f $1/docker-compose.yml --env-file bridgehead-config/$1.env up -d

log "The bridgehead should be in online in a few seconds"
