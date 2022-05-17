#!/bin/bash

source lib/functions.sh

checkOwner(){
  ## Check for file permissions
  COUNT=$(find $1 ! -user $2 |wc -l)
  if [ $COUNT -gt 0 ]; then
    log ERROR "$COUNT files in $1 are not owned by user $2. Run find $1 ! -user $2 to see them, chown -R $2 $1 to correct this issue."
    exit 1
  fi
}

if ! id "bridgehead" &>/dev/null; then
  log ERROR "User bridgehead does not exist. Please consult readme for installation."
  exit 1
fi

checkOwner . bridgehead
checkOwner /etc/bridgehead bridgehead

## Check if user is a su
log INFO "Checking if all prerequisites are met ..."
prerequisites="git docker docker-compose"
for prerequisite in $prerequisites; do
  $prerequisite --version 2>&1
  is_available=$?
  if [ $is_available -gt 0 ]; then
    log "ERROR" "Prerequisite not fulfilled - $prerequisite is not available!"
    exit 79
  fi
  # TODO: Check for specific version
done

log INFO "Checking configuration ..."

## Download submodule
if [ ! -d "/etc/bridgehead/" ]; then
  log ERROR "Please set up the config folder at /etc/bridgehead. Instruction are in the readme."
  exit 1
fi

# TODO: Check all required variables here in a generic loop

#check if project env is present
if [ -d "/etc/bridgehead/${PROJECT}.conf" ]; then
   log ERROR "Project config not found. Please copy the template from ${PROJECT} and put it under /etc/bridgehead-config/${PROJECT}.conf."
   exit 1
fi

# TODO: Make sure you're in the right directory, or, even better, be independent from the working directory.

log INFO "Checking ssl cert"

if [ ! -d "certs" ]; then
  log WARN "TLS cert missing, we'll now create a self-signed one. Please consider getting an officially signed one (e.g. via Let's Encrypt ...)"
  mkdir -p certs
fi

if [ ! -e "certs/traefik.crt" ]; then
  openssl req -x509 -newkey rsa:4096 -nodes -keyout certs/traefik.key -out certs/traefik.crt -days 3650 -subj "/CN=$HOST"
fi

if [ -e /etc/bridgehead/vault.conf ]; then
	if [ "$(stat -c "%a %U" /etc/bridgehead/vault.conf)" != "600 bridgehead" ]; then
		log ERROR "/etc/bridgehead/vault.conf has wrong owner/permissions. To correct this issue, run chmod 600 /etc/bridgehead/vault.conf && chown bridgehead /etc/bridgehead/vault.conf."
		exit 1
	fi
fi

log INFO "Success - all prerequisites are met!"

exit 0
