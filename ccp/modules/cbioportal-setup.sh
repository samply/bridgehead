#!/bin/bash -e

 if [ "$ENABLE_CBIOPORTAL" == true ]; then
  log INFO "cBioPortal setup detected -- will start cBioPortal service."
  OVERRIDE+=" -f ./$PROJECT/modules/cbioportal-compose.yml"
  CBIOPORTAL_DB_PASSWORD="$(echo \"This is a salt string to generate one consistent password for the cbioportal database. It is not required to be secret.\" | openssl rsautl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
  CBIOPORTAL_DB_ROOT_PASSWORD="$(echo \"This is a salt string to generate one consistent root password for the cbioportal database. It is not required to be secret.\" | openssl rsautl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 64)" 
 fi
