#!/bin/bash
### Note: Currently not complete, needs some features before useable for production

if ! ./prerequisites.sh; then
    echo "Prerequisites failed, exiting"
    exiting
fi
source site.conf

echo "Starting bridgehead"

cd ${project}

docker-compose --env-file ../site-config/${project}.env up -d

cd ..

echo "The bridgehead should be in online in a few seconds"
