#!/bin/bash -e

if [ -n "$ENABLE_OVIS" ]; then
  log INFO ""
  log INFO "######################################################################"
  log INFO "#    ___ __     _______ ____    __  __  ___  ____  _   _ _     _____ #"
  log INFO "#   / _ \\ \   / /_ _/ ___|   |  \\/  |/ _ \\|  _ \\| | | | |   | ____|#"
  log INFO "#  | | | |\\ \\ / / | |\\___ \\   | |\\/| | | | | | | | | | |   |  _|  #"
  log INFO "#  | |_| | \\ V /  | | ___) |  | |  | | |_| | |_| | |_| | |___| |___ #"
  log INFO "#   \\___/   \\_/  |___|____/   |_|  |_|\\___/|____/ \\___/|_____|_____|#"
  log INFO "#                                                                    #"
  log INFO "#          OVIS MODULE ENABLED - INITIALIZING AUTH + ROUTING         #"
  log INFO "######################################################################"
  log INFO ""
  log INFO "OVIS setup detected -- will start OVIS services with local oauth2-proxy middleware."
  TRUSTED_CA_DIR="/etc/bridgehead/trusted-ca-certs"
  OVIS_OAUTH2_PROXY_PROVIDER_CA_FILES=""

  if [ -d "$TRUSTED_CA_DIR" ]; then
    shopt -s nullglob
    ca_candidates=("$TRUSTED_CA_DIR"/*.crt "$TRUSTED_CA_DIR"/*.pem)
    shopt -u nullglob

    if [ ${#ca_candidates[@]} -gt 0 ]; then
      valid_ca_files=()
      for candidate in "${ca_candidates[@]}"; do
        if [ -f "$candidate" ] && grep -q "BEGIN CERTIFICATE" "$candidate"; then
          valid_ca_files+=("$candidate")
        else
          log WARN "Skipping non-certificate OIDC CA candidate: $candidate"
        fi
      done

      if [ ${#valid_ca_files[@]} -gt 0 ]; then
        OVIS_OAUTH2_PROXY_PROVIDER_CA_FILES="$(IFS=,; printf '%s' "${valid_ca_files[*]}")"
        log INFO "OVIS oauth2-proxy will trust OIDC provider CA files from $TRUSTED_CA_DIR (*.crt/*.pem certificates only)."
      else
        log INFO "No valid OIDC CA certificate files found in $TRUSTED_CA_DIR; oauth2-proxy will use system trust store only."
      fi
    else
      log INFO "No OIDC CA candidates (*.crt/*.pem) found in $TRUSTED_CA_DIR; oauth2-proxy will use system trust store only."
    fi
  else
    log INFO "Trusted CA directory $TRUSTED_CA_DIR is missing; oauth2-proxy will use system trust store only."
  fi

  OVERRIDE+=" -f ./$PROJECT/modules/ovis-compose.yml"
  add_private_oidc_redirect_url "/oauth2-ovis/callback"
fi
