#!/bin/bash
### Note: Currently not complete, needs some features before useable for production

source lib/functions.sh

exitIfNotRoot

if ! ./lib/prerequisites.sh; then
    log "Prerequisites failed, exiting"
    exit 1
fi
source site.conf

echo -e "\nInstalling systemd units ..."
cp -v \
    lib/systemd/bridgehead\@.service \
    lib/systemd/bridgehead-update\@.service \
    lib/systemd/bridgehead-update\@.timer \
    /etc/systemd/system/

systemctl daemon-reload

echo

if ! systemctl is-active --quiet bridgehead@"${project}"; then
    echo "Enabling autostart of bridgehead@${project}.service"
    systemctl enable bridgehead@"${project}"
    echo "Enabling nightly updates for bridgehead@${project}.service ..."
    systemctl enable --now bridgehead-update@"${project}".timer
fi

echo -e "\nDone - now start your bridgehead by running\n\tsystemctl start bridgehead@${project}.service\nor by rebooting your machine."

# TODO: Configuration of the different modules
