#!/bin/bash

if [ "$ENABLE_EXPORTER" == true ]; then
  log INFO "Exporter setup detected -- will start Exporter service."
  OVERRIDE+=" -f ./$PROJECT/modules/exporter-compose.yml"
  EXPORTER_DB_PASSWORD="$(echo \"This is a salt string to generate one consistent password for the exporter. It is not required to be secret.\" | openssl rsautl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
  EXPORTER_API_KEY="$(echo \"This is a salt string to generate one consistent API KEY for the exporter. It is not required to be secret.\" | openssl rsautl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 64)"
fi
