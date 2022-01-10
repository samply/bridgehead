#!/bin/bash -e

source lib/functions.sh
source site.conf

log "Stopping bridgehead"

cd ${project}

docker-compose --env-file ../site-config/${project}.env down

cd ..
