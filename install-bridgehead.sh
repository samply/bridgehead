#!/bin/bash
### Note: Currently not complete, needs some features before useable for production

./prerequisites.sh
source site.conf

echo "Installing bridgehead"

cd /etc/systemd/system/

echo "Installing bridgehead\@.service in systemd ..."
sudo cp /srv/docker/bridgehead/convenience/bridgehead\@.service ./
echo "Installing bridgehead\@.update.service in systemd ..."
sudo cp /srv/docker/bridgehead/convenience/bridgehead-update\@.service ./
sudo cp /srv/docker/bridgehead/convenience/bridgehead-update\@.timer ./

echo "Loading the bridgehead definitions in systemd"
sudo systemctl daemon-reload


echo "Starting Project ${project} "
  if [ ! -f "/etc/systemd/system/bridgehead@${project}.service.d/bridgehead.conf" ]; then
    echo "Can't find local configuration file for bridgehead@${project} service. Please ensure that the file /etc/systemd/system/bridgehead@${project}.service.d/bridgehead.conf exists"
    exit
  fi

  sudo systemctl is-active --quiet bridgehead@"${project}"
  if [ ! $? -eq 0 ]; then
    echo "Starting bridgehead@${project} service ..."
    sudo systemctl start bridgehead@"${project}"
    echo "Enabling autostart of bridgehead@${project}.service"
    sudo systemctl enable bridgehead@"${project}"
    echo "Enabling nightly updates for bridgehead@${project}.service ..."
    sudo systemctl enable --now bridgehead-update@"${project}".timer
  fi

# Switch back to execution directory;
cd -
# TODO: Configuration of the different modules
