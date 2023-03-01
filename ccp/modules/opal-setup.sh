#!/bin/bash

if [ "$ENABLE_OPAL" == true ];then
  log INFO "Opal setup detected -- will start Opal services."
  OVERRIDE+=" -f ./$PROJECT/modules/opal-compose.yml"
fi
OPAL_DB_PASSWORD="$(echo \"This is a salt string to generate one consistent password. It is not required to be secret.\" | openssl rsautl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
