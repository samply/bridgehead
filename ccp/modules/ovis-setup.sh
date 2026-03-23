#!/bin/bash -e

if [ -n "$ENABLE_OVIS" ]; then
  if declare -F log >/dev/null 2>&1; then
    log INFO "OVIS setup detected -- will start OVIS services."
  fi

  OVERRIDE+=" -f ./$PROJECT/modules/ovis-compose.yml"
fi
