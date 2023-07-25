#!/bin/bash -e

source lib/functions.sh

exitIfNotRoot

if [ $# -eq 0 ]; then
    log "ERROR" "Please provide a Project as argument"
    exit 1
fi

export PROJECT=$1

checkRequirements noprivkey

log "INFO" "Allowing the bridgehead user to start/stop the bridgehead."

cat <<EOF > /etc/sudoers.d/bridgehead-"${PROJECT}"
# This has been added by the Bridgehead installer. Remove with bridgehead uninstall.
Cmnd_Alias BRIDGEHEAD${PROJECT^^} = \\
    /bin/systemctl start bridgehead@${PROJECT}.service, \\
    /bin/systemctl stop bridgehead@${PROJECT}.service, \\
    /bin/systemctl restart bridgehead@${PROJECT}.service, \\
    /bin/systemctl restart bridgehead@*.service, \\
    /bin/chown -R bridgehead /etc/bridgehead /srv/docker/bridgehead, \\
    /usr/bin/chown -R bridgehead /etc/bridgehead /srv/docker/bridgehead

bridgehead ALL= NOPASSWD: BRIDGEHEAD${PROJECT^^}
EOF

# TODO: Determine whether this should be located in setup-bridgehead (triggered through bridgehead install) or in update bridgehead (triggered every hour)
if [ -z "$LDM_PASSWORD" ]; then
  log "INFO" "Now generating a password for the local data management. Please save the password for your ETL process!"
  generated_passwd="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 32)"

  log "INFO" "Your generated credentials are:\n            user: $PROJECT\n            password: $generated_passwd"
  addBasicAuthUser $PROJECT $generated_passwd "LDM_LOGIN" $PROJECT
fi

log "INFO" "Registering system units for bridgehead and bridgehead-update"
cp -v \
    lib/systemd/bridgehead\@.service \
    lib/systemd/bridgehead-update\@.service \
    lib/systemd/bridgehead-update\@.timer \
    /etc/systemd/system/

systemctl daemon-reload

log INFO "Trying to update your bridgehead ..."

systemctl start bridgehead-update@"${PROJECT}".service

log "INFO" "Enabling autostart of bridgehead@${PROJECT}.service"
systemctl enable bridgehead@"${PROJECT}".service

log "INFO" "Enabling auto-updates for bridgehead@${PROJECT}.service ..."
systemctl enable --now bridgehead-update@"${PROJECT}".timer

STR="\n\n            systemctl start bridgehead@${PROJECT}.service\n\nor by rebooting your machine."
if [ -e /etc/bridgehead/pki/${SITE_ID}.priv.pem ]; then
  STR="Success. Next, start your bridgehead by running$STR"
else
  STR="Success. Next, enroll into the $PROJECT broker by creating a cryptographic certificate. To do so, run\n\n            /srv/docker/bridgehead/bridgehead enroll $PROJECT\n\nThen, you may start the bridgehead by running$STR"
fi

log "INFO" "$STR"
