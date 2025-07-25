#!/bin/bash

if [ -n "$ENABLE_PSCC" ];then
  OVERRIDE+=" -f ./$PROJECT/modules/pscc-compose.yml"
fi