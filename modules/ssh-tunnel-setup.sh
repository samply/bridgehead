#!/bin/bash

if [ -n "$ENABLE_SSH_TUNNEL" ]; then
	log INFO "SSH Tunnel setup detected -- will start SSH Tunnel."
	OVERRIDE+=" -f ./modules/ssh-tunnel-compose.yml"
fi
