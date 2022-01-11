#!/bin/bash -e

source lib/functions.sh
source site.conf

log "Stopping bridgehead"

docker-compose -f ${project}/docker-compose.yml --env-file site-config/${project}.env down

