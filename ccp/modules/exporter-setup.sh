#!/bin/bash

if [ -n "$ENABLE_EXPORTER" ];then
  log INFO "Exporter setup detected -- will start Exporter service."
  OVERRIDE+=" -f ./$PROJECT/modules/exporter-compose.yml"
fi
# TODO: Generate password in another way so that not all passwords are the same?
EXPORTER_DB_PASSWORD="$(echo \"This is a salt string to generate one consistent password for the exporter. It is not required to be secret.\" | openssl rsautl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
