#!/bin/bash
### Note: Currently not complete, needs some features before useable for production

source lib/functions.sh

exitIfNotRoot

if ! ./lib/prerequisites.sh; then
    echo "Prerequisites failed, exiting"
    exit 1
fi
source site.conf

_systemd_path=/etc/systemd/system/


echo -e "\nInstalling systemd units ..."
cp -v \
    convenience/bridgehead\@.service \
    convenience/bridgehead-update\@.service \
    convenience/bridgehead-update\@.timer \
    $_systemd_path

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
