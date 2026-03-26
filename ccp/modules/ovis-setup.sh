#!/bin/bash -e

if [ -n "$ENABLE_OVIS" ]; then
  log INFO "OVIS setup detected -- will start OVIS services with local oauth2-proxy middleware."
  TRUSTED_CA_DIR="/etc/bridgehead/trusted-ca-certs"
  OVIS_OAUTH2_PROXY_PROVIDER_CA_FILES=""

  if [ -d "$TRUSTED_CA_DIR" ]; then
    shopt -s nullglob
    ca_cert_candidates=("$TRUSTED_CA_DIR"/*.crt)
    shopt -u nullglob

    if [ ${#ca_cert_candidates[@]} -gt 0 ]; then
      OVIS_OAUTH2_PROXY_PROVIDER_CA_FILES="$(IFS=,; printf '%s' "${ca_cert_candidates[*]}")"
      log INFO "OVIS oauth2-proxy will trust OIDC provider CA files from $TRUSTED_CA_DIR (*.crt)."
    else
      log INFO "No *.crt files found in $TRUSTED_CA_DIR; oauth2-proxy will use system trust store only."
    fi
  else
    log INFO "Trusted CA directory $TRUSTED_CA_DIR is missing; oauth2-proxy will use system trust store only."
  fi

  OVERRIDE+=" -f ./$PROJECT/modules/ovis-compose.yml"
  add_private_oidc_redirect_url "/oauth2-ovis/callback"
fi
