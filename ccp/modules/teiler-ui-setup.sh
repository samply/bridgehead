#!/bin/bash

if [ "$ENABLE_TEILER" == true ];then
  log INFO "Teiler-UI setup detected -- will start Teiler-UI services."
  OVERRIDE+=" -f ./$PROJECT/modules/teiler-ui-compose.yml"
fi
