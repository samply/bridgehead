#!/bin/bash

# Start a running Bridgehead. If there is already a Bridgehead running,
# stop it first.
# This is intended to be used by systemctl.

cd /srv/docker/bridgehead

echo "git status before stop"
git status

echo "Stopping running Bridgehead, if present"
./bridgehead stop bbmri

# If "flush_blaze" is present, delete the Blaze volume before starting
# the Bridgehead again. This allows a user to upload all data, if
# requested.
if [ -f "/srv/docker/ecdc/data/flush_blaze" ]; then
    docker volume rm bbmri_blaze-data
    rm -f /srv/docker/ecdc/data/flush_blaze
fi

echo "git status before start"
git status | systemd-cat -p info

echo "Start the Bridgehead anew"
./bridgehead start bbmri

echo "Bridgehead has unexpectedly terminated"

