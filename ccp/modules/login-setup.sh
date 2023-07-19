#!/bin/bash

if [ "$ENABLE_LOGIN" == true ]; then
  log INFO "Login setup detected -- will start Login services."
  OVERRIDE+=" -f ./$PROJECT/modules/login-compose.yml"
  KEYCLOAK_DB_PASSWORD="$(echo \"This is a salt string to generate one consistent password for Keycloak. It is not required to be secret.\" | openssl rsautl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
fi
