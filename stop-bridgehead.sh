#!/bin/bash -e

source lib/functions.sh

log "Stopping bridgehead"

# TODO: Check $1 for proper values
docker-compose -f $1/docker-compose.yml --env-file bridgehead-config/$1.env down
