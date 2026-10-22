#!/bin/bash

if [ "$ENABLE_DATA_QUALITY_AGENT" == "true" ]; then
    log INFO "Data Quality Agent setup detected -- will start data-quality-agent service."
    export BRIDGEHEAD_UID="$(id -u bridgehead)"
    export BRIDGEHEAD_GID="$(id -g bridgehead)"
    OVERRIDE+=" -f ./$PROJECT/modules/data-quality-agent-compose.yml"
fi

