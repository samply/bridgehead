#!/bin/bash

source lib/functions.sh

## Check for file permissions
if ! id "bridgehead" &>/dev/null; then
  log ERROR "User bridgehead does not exist. Please consult readme for installation."
  exit 1
fi
COUNT=$(find . ! -user bridgehead |wc -l)
if [ $COUNT -gt 0 ]; then
  log ERROR "$COUNT files in $(pwd) are not owned by user bridgehead. Run find $(pwd) ! -user bridgehead to see them, chown -R bridgehead $(pwd) to correct this issue."
  exit 1
fi

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

#check if site.conf is created
if [ ! -f /etc/bridgehead/site.conf ]; then
  log ERROR "Please create your specific site.conf file from the site.dev.conf"
  exit 1
fi

#Load site specific variables
source /etc/bridgehead/site.conf

# TODO: Check all required variables here in a generic loop

if [ -z "$SITE_NAME" ]; then
  log ERROR "Please set SITE_NAME."
  exit 1
fi

#check if project env is present
if [ -d "/etc/bridgehead/${PROJECT}.env" ]; then
   log ERROR "Project config not found. Please copy the template from ${PROJECT} and put it under /etc/bridgehead-config/${PROJECT}.env."
   exit 1
fi

# TODO: Make sure you're in the right directory, or, even better, be independent from the working directory.

log INFO "Checking ssl cert"

if [ ! -d "certs" ]; then
  log WARN "TLS cert missing, we'll now create a self-signed one. Please consider getting an officially signed one (e.g. via Let's Encrypt ...)"
  mkdir -p certs
fi

if [ ! -e "certs/traefik.crt" ]; then
  openssl req -x509 -newkey rsa:4096 -nodes -keyout certs/traefik.key -out certs/traefik.crt -days 365
fi

log INFO "Success - all prerequisites are met!"

exit 0
