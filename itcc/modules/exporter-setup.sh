#!/bin/bash -e

if [ "$ENABLE_EXPORTER" == true ]; then
  log INFO "Exporter setup detected -- will start Exporter and Reporter services."
  OVERRIDE+=" -f ./$PROJECT/modules/exporter-compose.yml"
  EXPORTER_DB_PASSWORD="$(generate_simple_password 'exporter-db')"
  EXPORTER_API_KEY="$(generate_simple_password 'exporter')"
fi
