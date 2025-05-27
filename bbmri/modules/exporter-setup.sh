#!/bin/bash -e

if [ "$ENABLE_EXPORTER" == true ]; then
  log INFO "Exporter setup detected -- will start Exporter service."
  OVERRIDE+=" -f ./$PROJECT/modules/exporter-compose.yml"
  EXPORTER_DB_PASSWORD="$(echo \"This is a salt string to generate one consistent password for the exporter. It is not required to be secret.\" | sha1sum | openssl pkeyutl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
  EXPORTER_API_KEY="$(echo \"This is a salt string to generate one consistent API KEY for the exporter. It is not required to be secret.\" | sha1sum | openssl pkeyutl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 64)"

  if [ -z "$EXPORTER_USER" ]; then
    log "INFO" "Now generating basic auth for the exporter and reporter (see adduser in bridgehead for more information). "
    generated_passwd="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 32)"
    add_basic_auth_user $PROJECT $generated_passwd "EXPORTER_USER" $PROJECT
  fi

fi
