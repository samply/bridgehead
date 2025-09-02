#!/bin/bash -e

function scoutSetup() {
    if [[ -n "$ENABLE_SCOUT" && -n "$SCOUT_BASIC_AUTH_USERS" ]]; then
        echo "Starting scout."
	    OVERRIDE+=" -f ./modules/scout-compose.yml"
    fi
}
