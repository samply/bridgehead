#!/bin/bash

function nngmSetup() {
	if [ -n "$NNGM_CTS_APIKEY" ]; then
		log INFO "nNGM setup detected -- will start nNGM Connector."
		OVERRIDE+="-f ./$PROJECT/nngm-compose.yml"
	fi
}

#CONNECTOR_POSTGRES_PASSWORD="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
CONNECTOR_POSTGRES_PASSWORD="$(echo -n /etc/bridgehead/pki/mannheim.priv.pem | sha256sum | head -c 20)"
