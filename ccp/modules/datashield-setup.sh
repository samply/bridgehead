#!/bin/bash -e

if [ "$ENABLE_DATASHIELD" == true ]; then
  log INFO "DataSHIELD setup detected -- will start DataSHIELD services."
  OVERRIDE+=" -f ./$PROJECT/modules/datashield-compose.yml"
  OPAL_DB_PASSWORD="$(echo \"This is a salt string to generate one consistent password for Opal. It is not required to be secret.\" | openssl rsautl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
  DATASHIELD_CONNECT_SECRET="$(echo \"This is a salt string to generate one consistent password as the DataShield Connect secret. It is not required to be secret.\" | openssl rsautl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
  if [ ! -e /tmp/bridgehead/opal-cert.pem ]; then
    mkdir -p /tmp/bridgehead/
    chown -R bridgehead:docker /tmp/bridgehead/
    openssl req -x509 -newkey rsa:4096 -nodes -keyout /tmp/bridgehead/opal-key.pem -out /tmp/bridgehead/opal-cert.pem -days 3650 -subj "/CN=${HOST:-opal}/C=DE"
    chown -R bridgehead:docker /tmp/bridgehead/
    chmod g+r /tmp/bridgehead/opal-key.pem
  fi
fi
