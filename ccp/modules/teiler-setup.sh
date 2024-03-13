#!/bin/bash -e

if [ "$ENABLE_TEILER" == true ];then
  log INFO "Teiler setup detected -- will start Teiler services."
  OVERRIDE+=" -f ./$PROJECT/modules/teiler-compose.yml"
  DEFAULT_LANGUAGE=DE
  DEFAULT_LANGUAGE_LOWER_CASE=${DEFAULT_LANGUAGE,,}
  add_public_oidc_redirect_url "/ccp-teiler/*"
fi
