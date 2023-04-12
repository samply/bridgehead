#!/bin/bash

if [ "$ENABLE_DATASHIELD" == true ];then
  log INFO "DataSHIELD setup detected -- will start DataSHIELD services."
  OVERRIDE+=" -f ./$PROJECT/modules/datashield-compose.yml"
fi
OPAL_DB_PASSWORD="$(echo \"This is a salt string to generate one consistent password for Opal. It is not required to be secret.\" | openssl rsautl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
