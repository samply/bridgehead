#!/bin/bash
### Note: Currently not complete, needs some features before useable for production

source lib/functions.sh

if ! ./prerequisites.sh; then
    log "Prerequisites failed, exiting"
    exit
fi
source site.conf

log "Starting bridgehead"

cd ${project}

docker-compose --env-file ../site-config/${project}.env up -d

cd ..

log "The bridgehead should be in online in a few seconds"
