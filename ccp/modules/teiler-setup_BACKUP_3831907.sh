#!/bin/bash -e

if [ "$ENABLE_TEILER" == true ];then
  log INFO "Teiler setup detected -- will start Teiler services."
  OVERRIDE+=" -f ./ccp/modules/teiler-compose.yml"
<<<<<<< HEAD
  TEILER_DEFAULT_LANGUAGE=DE
  TEILER_DEFAULT_LANGUAGE_LOWER_CASE=${TEILER_DEFAULT_LANGUAGE,,}
=======
>>>>>>> 6476529abd2103e8d5bd4fcdecbec27d1c633f37
  add_public_oidc_redirect_url "/ccp-teiler/*"
fi
