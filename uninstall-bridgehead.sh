#!/bin/bash -e

source site.conf
source lib/functions.sh

echo "Stopping systemd services and removing bridgehead ..."

systemctl disable --now bridgehead@${project}.service
systemctl disable --now bridgehead-update@${project}.timer
systemctl disable --now bridgehead-update@${project}.service

rm -v /etc/systemd/system/{bridgehead\@.service,bridgehead-update\@.timer,bridgehead-update\@.service}
