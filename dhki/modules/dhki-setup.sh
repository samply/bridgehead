#!/bin/bash
log INFO "DKFZ-Hector setup detected -- will start services for DKFZ-Hector."

# The environment needs to be defined in /etc/bridgehead
case "$ENVIRONMENT" in
	"production")
		export BROKER_ID=broker.hector.dkfz.de
		export DHKI_ROOT_CERT=dhki
		;;
	"development")
		export BROKER_ID=broker.dev.hector.dkfz.de
		export DHKI_ROOT_CERT=dhki.dev
		;;
	*)
		report_error 6 "Environment \"$ENVIRONMENT\" is unknown. Assuming production. FIX THIS!"
		export BROKER_ID=broker.hector.dkfz.de
		export DHKI_ROOT_CERT=dhki
		;;
esac
