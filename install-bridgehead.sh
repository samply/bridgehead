#!/bin/bash
### Note: Currently not complete, needs some features before useable for production

source lib/functions.sh

exitIfNotRoot

if ! ./lib/prerequisites.sh; then
    echo "Prerequisites failed, exiting"
    exit 1
fi
source site.conf

echo "Installing bridgehead"

_systemd_path=/etc/systemd/system/


echo "Installing systemd units ..."
cp -v \
	convenience/bridgehead\@.service \
	convenience/bridgehead-update\@.service \
	convenience/bridgehead-update\@.timer \
	$_systemd_path

echo "Loading the bridgehead definitions in systemd"
systemctl daemon-reload


echo "Starting Project ${project} "
  if [ ! -f "/etc/systemd/system/bridgehead@${project}.service.d/bridgehead.conf" ]; then
    echo "Can't find local configuration file for bridgehead@${project} service. Please ensure that the file /etc/systemd/system/bridgehead@${project}.service.d/bridgehead.conf exists"
    exit
  fi

  systemctl is-active --quiet bridgehead@"${project}"
  if [ ! $? -eq 0 ]; then
    echo "Starting bridgehead@${project} service ..."
    systemctl start bridgehead@"${project}"
    echo "Enabling autostart of bridgehead@${project}.service"
    systemctl enable bridgehead@"${project}"
    echo "Enabling nightly updates for bridgehead@${project}.service ..."
    systemctl enable --now bridgehead-update@"${project}".timer
  fi

# Switch back to execution directory;
cd -
# TODO: Configuration of the different modules
