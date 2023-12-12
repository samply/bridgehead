#!/bin/bash -e

if [ "$ENABLE_DATASHIELD" == true ]; then
  log INFO "DataSHIELD setup detected -- will start DataSHIELD services."
  OVERRIDE+=" -f ./$PROJECT/modules/datashield-compose.yml"
  EXPORTER_OPAL_PASSWORD="$(generate_password \"exporter in Opal\")"
  TOKEN_MANAGER_OPAL_PASSWORD="$(generate_password \"Token Manager in Opal\")"
  OPAL_DB_PASSWORD="$(echo \"This is a salt string to generate one consistent password for Opal. It is not required to be secret.\" | openssl rsautl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
  OPAL_ADMIN_PASSWORD="$(generate_password \"admin password for Opal\")"
  RSTUDIO_ADMIN_PASSWORD="$(generate_password \"admin password for R-Studio\")"
  DATASHIELD_CONNECT_SECRET="$(echo \"This is a salt string to generate one consistent password as the DataShield Connect secret. It is not required to be secret.\" | openssl rsautl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
  TOKEN_MANAGER_SECRET="$(echo \"This is a salt string to generate one consistent password as the Token Manger secret. It is not required to be secret.\" | openssl rsautl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
  if [ ! -e /tmp/bridgehead/opal-cert.pem ]; then
    mkdir -p /tmp/bridgehead/
    chown -R bridgehead:docker /tmp/bridgehead/
    openssl req -x509 -newkey rsa:4096 -nodes -keyout /tmp/bridgehead/opal-key.pem -out /tmp/bridgehead/opal-cert.pem -days 3650 -subj "/CN=${HOST:-opal}/C=DE"
    chmod g+r /tmp/bridgehead/opal-key.pem
  fi
  mkdir -p /tmp/bridgehead/opal-map
  jq -n --argfile input ./$PROJECT/modules/datashield-mappings.json '
    [{
        "external": "opal-'"$SITE_ID"'",
        "internal": "opal:8080",
        "allowed": [$input.sites[].id | "datashield-connect.\(.).broker.ccp-it.dktk.dkfz.de"]
    }]' >/tmp/bridgehead/opal-map/local.json
  cp -f ./$PROJECT/modules/datashield-mappings.json /tmp/bridgehead/opal-map/central.json
  chown -R bridgehead:docker /tmp/bridgehead/
  add_private_oidc_redirect_url "/opal/*"
fi
