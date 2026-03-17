#!/bin/bash
if [ -n "$ENABLE_OSIRIS2FHIR" ]; then
  log INFO "oBDS2FHIR-REST setup detected -- will start osiris2fhir module."
  OVERRIDE+=" -f ./pscc/modules/osiris2fhir-compose.yml"
  LOCAL_SALT="$(echo \"local-random-salt\" | openssl pkeyutl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
fi