#!/bin/bash
### Note: Currently not complete, needs some features before useable for production

source lib/functions.sh

if ! lib/prerequisites.sh; then
    log "Prerequisites failed, exiting"
    exit
fi
source site.conf

./lib/generate.sh

log "Starting bridgehead"

docker-compose -f <(docker run --rm --volume ${pwd}/${project}/:/tmp/workdir/ samply/templer /tmp/workdir/docker-compose.yml TEST="TEST_0 TEST_1") config

log "The bridgehead should be in online in a few seconds"
