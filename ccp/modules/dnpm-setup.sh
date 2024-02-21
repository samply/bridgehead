#!/bin/bash

if [ -n "${ENABLE_DNPM}" ]; then
	log INFO "DNPM setup detected (Beam.Connect) -- will start Beam.Connect for DNPM."
	OVERRIDE+=" -f ./$PROJECT/modules/dnpm-compose.yml"

	# Set variables required for Beam-Connect
	DNPM_BEAM_SECRET_SHORT="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
	# If the DNPM_NO_PROXY variable is set, prefix it with a comma (as it gets added to a comma separated list)
	if [ -n "${DNPM_NO_PROXY}" ]; then
		DNPM_ADDITIONAL_NO_PROXY=",${DNPM_NO_PROXY}"
	else
		DNPM_ADDITIONAL_NO_PROXY=""
	fi
fi
