#!/bin/bash


## Check if user is a su
log "Welcome to the starting a bridgehead. We will get your instance up and running in no time"
log "First we will check if all prerequisites are met ..."
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

log "Checking /etc/bridgehead/"

## Download submodule
if [ ! -d "/etc/bridgehead/" ]; then
  log "Please set up the config folder. Instruction are in the readme."
  exit 1
else
  log "Done"
fi

log "Checking /etc/bridgehead/site.conf"

#check if site.conf is created
if [ ! -f /etc/bridgehead/site.conf ]; then
  log "Please create your specific site.conf file from the site.dev.conf"
  exit 1
else
  log "Done"
fi

#Load site specific variables
source /etc/bridgehead/site.conf

if [ -z "$site_name" ]; then
  log "Please set site_name"
  exit 1
fi

log "Checking project config"

#check if project env is present
if [ -d "/etc/bridgehead/${project}.env" ]; then
   log "Please copy the tempalte from ${project} and put it in the /etc/bridgehead-config/ folder"
   exit 1
else 
  log "Done"
fi

log "Checking ssl cert"

## Create SSL Cert
if [ ! -d "/certs" ]; then
  log "SSL cert missing, now we create one. Please consider getting a signed one"
  mkdir certs
fi

if [ -d "certs/traefik.crt" ]; then
  openssl req -x509 -newkey rsa:4096 -nodes -keyout certs/traefik.key -out certs/traefik.crt -days 365
fi

log "All prerequisites are met!"
