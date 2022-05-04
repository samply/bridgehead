#!/bin/bash
### Note: Currently not complete, needs some features before useable for production

source lib/functions.sh

<<<<<<< HEAD
exitIfNotRoot

if [ $# -eq 0 ]; then
    echo "Please provide a Project as argument"
    exit 1
fi

if [ $1 != "ccp" ] && [ $1 != "nngm" ] && [ $1 != "gbn" ]; then
    echo "Please provide a supported project like ccp, gbn or nngm"
    exit 1
fi

export project=$1

=======
>>>>>>> 290fe5459d7399ff23a2a8db067c1728858350d5
if ! ./lib/prerequisites.sh; then
    log "Prerequisites failed, exiting"
    exit 1
fi

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
