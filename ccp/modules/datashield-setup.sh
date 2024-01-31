#!/bin/bash -e

if [ "$ENABLE_DATASHIELD" == true ]; then
  log INFO "DataSHIELD setup detected -- will start DataSHIELD services."
  OVERRIDE+=" -f ./$PROJECT/modules/datashield-compose.yml"
  EXPORTER_OPAL_PASSWORD="$(generate_password \"exporter in Opal\")"
  TOKEN_MANAGER_OPAL_PASSWORD="$(generate_password \"Token Manager in Opal\")"
  OPAL_DB_PASSWORD="$(echo \"Opal DB\" | generate_simple_password)"
  OPAL_ADMIN_PASSWORD="$(generate_password \"admin password for Opal\")"
  RSTUDIO_ADMIN_PASSWORD="$(generate_password \"admin password for R-Studio\")"
  DATASHIELD_CONNECT_SECRET="$(echo \"DataShield Connect\" | generate_simple_password)"
  TOKEN_MANAGER_SECRET="$(echo \"Token Manager\" | generate_simple_password)"
  if [ ! -e /tmp/bridgehead/opal-cert.pem ]; then
    mkdir -p /tmp/bridgehead/
    chown -R bridgehead:docker /tmp/bridgehead/
    openssl req -x509 -newkey rsa:4096 -nodes -keyout /tmp/bridgehead/opal-key.pem -out /tmp/bridgehead/opal-cert.pem -days 3650 -subj "/CN=opal/C=DE"
    chmod g+r /tmp/bridgehead/opal-key.pem
  fi
  mkdir -p /tmp/bridgehead/opal-map
  sites="$(cat ./$PROJECT/modules/datashield-mappings.json)"
  echo "$sites" | docker_jq -n --args '{"sites": input | map({
    "name": .,
    "id": .,
    "virtualhost": "\(.):443",
    "beamconnect": "datashield-connect.\(.).'"$BROKER_ID"'"
  })}' $sites > /tmp/bridgehead/opal-map/central.json
  echo "$sites" | docker_jq -n --args '[{
    "external": "'"$SITE_ID"':443",
    "internal": "opal:8443",
    "allowed": input | map("datashield-connect.\(.).'"$BROKER_ID"'")
  }]' > /tmp/bridgehead/opal-map/local.json
  chown -R bridgehead:docker /tmp/bridgehead/*
  add_private_oidc_redirect_url "/opal/*"
fi
