#!/bin/bash -e

if [ "$ENABLE_LOGIN" == true ]; then
  log INFO "Login setup detected -- will start Login services."
  OVERRIDE+=" -f ./$PROJECT/modules/login-compose.yml"
  KEYCLOAK_DB_PASSWORD="$(generate_password \"local Keycloak\")"
fi
