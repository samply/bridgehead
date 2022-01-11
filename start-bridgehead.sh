#!/bin/bash
### Note: Currently not complete, needs some features before useable for production

source lib/functions.sh

if ! lib/prerequisites.sh; then
    log "Prerequisites failed, exiting"
    exit
fi
source site.conf

log "Starting bridgehead"

docker-compose -f ${project}/docker-compose.yml --env-file site-config/${project}.env up -d

log "The bridgehead should be in online in a few seconds"
