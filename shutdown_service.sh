#!/bin/bash

# Shut down a running Bridgehead.
# This is intended to be used by systemctl.

cd /srv/docker/bridgehead

echo "git status before stop"
git status

echo "Stopping running Bridgehead, if present"
./bridgehead stop bbmri

