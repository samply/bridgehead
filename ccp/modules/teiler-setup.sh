#!/bin/bash -e

if [ "$ENABLE_TEILER" == true ];then
  log INFO "Teiler setup detected -- will start Teiler services."
  OVERRIDE+=" -f ./$PROJECT/modules/teiler-compose.yml"
  generate_public_oidc_client "OIDC_PUBLIC" "$(generate_redirect_urls '/ccp-teiler/*')"
fi
