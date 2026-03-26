#!/bin/bash -e

if [ -n "$ENABLE_OVIS" ]; then
  log INFO "OVIS setup detected -- will start OVIS services with local oauth2-proxy middleware."
  TRUSTED_CA_DIR="/etc/bridgehead/trusted-ca-certs"

  if [ -d "$TRUSTED_CA_DIR" ]; then
    shopt -s nullglob
    ca_candidates=("$TRUSTED_CA_DIR"/*.crt "$TRUSTED_CA_DIR"/*.pem)
    shopt -u nullglob

    if [ ${#ca_candidates[@]} -gt 0 ]; then
      OVIS_OAUTH2_PROXY_PROVIDER_CA_FILES="$(IFS=,; printf '%s' "${ca_candidates[*]}")"
      log INFO "OVIS oauth2-proxy will trust custom OIDC CA files from $TRUSTED_CA_DIR."
    else
      log INFO "No custom OIDC CA files (*.crt/*.pem) found in $TRUSTED_CA_DIR; using container system trust store only."
    fi
  fi

  OVERRIDE+=" -f ./$PROJECT/modules/ovis-compose.yml"
  add_private_oidc_redirect_url "/oauth2-ovis/callback"
fi
