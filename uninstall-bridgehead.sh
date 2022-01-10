#!/bin/bash -e

source site.conf
source lib/functions.sh

echo "Stopping systemd services and removing bridgehead ..."

for i in bridgehead\@.service bridgehead-update\@.timer bridgehead-update\@.service; do
  systemctl disable $i --now
  rm -v /etc/systemd/system/$i
done
