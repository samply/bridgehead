#!/bin/bash -e

if [ "$ENABLE_FHIR2SQL" == true ]; then
  log INFO "Dashboard setup detected -- will start Dashboard backend and FHIR2SQL service."
  OVERRIDE+=" -f ./common/fhir2sql-compose.yml"
  DASHBOARD_DB_PASSWORD="$(generate_simple_password 'fhir2sql')"
fi
