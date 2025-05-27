#!/bin/bash -e

if [ "$ENABLE_TEILER" == true ];then
  log INFO "Teiler setup detected -- will start Teiler services."
  OVERRIDE+=" -f ./$PROJECT/modules/teiler-compose.yml"
  TEILER_DEFAULT_LANGUAGE=EN
  TEILER_DEFAULT_LANGUAGE_LOWER_CASE=${TEILER_DEFAULT_LANGUAGE,,}
fi
