#!/bin/bash -e

if [ "$ENABLE_TEILER" == true ];then
  log INFO "Teiler setup detected -- will start Teiler services."
  OVERRIDE+=" -f ./$PROJECT/modules/teiler-compose.yml"
  redirect_urls="https://${HOST}/ccp-teiler/*"
  host_without_proxy="$(echo "$HOST" | cut -d '.' -f1)"
  if [[ "$HOST" != "$host_without_proxy" ]]; then
    redirect_urls+=",https://$host_without_proxy/ccp-teiler/*"
  fi
  generate_public_oidc_client "OIDC_PUBLIC" "$redirect_urls"
fi
