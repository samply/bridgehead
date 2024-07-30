#!/bin/bash -e

if [ "$ENABLE_FHIR2SQL" == true ]; then
  log INFO "Dashboard setup detected -- will start Dashboard backend and FHIR2SQL service."
  OVERRIDE+=" -f ./$PROJECT/modules/fhir2sql-compose.yml"
  DASHBOARD_DB_PASSWORD="$(echo \"This is a salt string to generate one consistent password for the Dashboard database. It is not required to be secret.\" | sha1sum | openssl pkeyutl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
fi
