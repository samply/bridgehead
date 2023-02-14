#!/bin/bash

if [ -n "$ENABLE_MTBA" ];then
  log INFO "MTBA setup detected -- will start MTBA Service and CBioPortal."
  if [ ! -n "$IDMANAGER_UPLOAD_APIKEY" ]; then
    log ERROR "Detected MTBA Module configuration but ID-Management Module seems not to be configured!"
    exit 1;
  fi
  OVERRIDE+=" -f ./$PROJECT/modules/mtba-compose.yml"
fi
