#!/bin/bash

function exliquidSetup() {
	if [ -n "$EXLIQUID" ]; then
		log INFO "EXLIQUID setup detected -- will start Reporthub."
		OVERRIDE+="-f ./$PROJECT/exliquid-compose.yml"
	fi
}