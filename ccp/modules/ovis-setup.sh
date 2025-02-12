#!/bin/bash -e

if [ -n "$ENABLE_OVIS" ];then

    OVERRIDE+=" -f ./$PROJECT/modules/ovis-compose.yml"
fi
