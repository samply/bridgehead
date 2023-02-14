#!/bin/bash

if [ "$ENABLE_TEILER" == true ];then
  log INFO "Teiler-UI setup detected -- will start Teiler-UI services."
  OVERRIDE+=" -f ./$PROJECT/modules/teiler-ui-compose.yml"
fi
KEYCLOAK_DB_PASSWORD="$(echo \"This is a salt string to generate one consistent password. It is not required to be secret.\" | openssl rsautl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
