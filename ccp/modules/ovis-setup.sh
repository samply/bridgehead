#!/bin/bash -e

if [ -n "$ENABLE_OVIS" ]; then
  log INFO "OVIS setup detected -- will start OVIS services with local oauth2-proxy middleware."
  OVERRIDE+=" -f ./$PROJECT/modules/ovis-compose.yml"
  add_private_oidc_redirect_url "/oauth2-ovis/callback"
fi
