#!/bin/bash

<<<<<<< HEAD

## Check if user is a su
echo "Welcome to the starting a bridgehead. We will get your instance up and running in no time"
echo "First we will check if all prerequisites are met ..."
=======
source lib/functions.sh

if ! id "bridgehead" &>/dev/null; then
  log ERROR "User bridgehead does not exist. Please consult readme for installation."
  exit 1
fi

checkOwner . bridgehead || exit 1
checkOwner /etc/bridgehead bridgehead || exit 1

## Check if user is a su
log INFO "Checking if all prerequisites are met ..."
>>>>>>> version-1
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

<<<<<<< HEAD
echo "Checking site.conf"

#check if site.conf is created
if [ ! -f site.conf ]; then
  echo "Please create your specific site.conf file from the site.dev.conf"
  exit
fi

#Load site specific variables
source site.conf

if [ -z "$site_name" ]; then
  echo "Please set site_name"
fi

echo "Checking site-config module"

## Download submodule
if [ ! -d "site-config" ]; then
  echo "Please set up the site-config folder. Instruction are in the readme."
  exit
else
  echo "Site configuration is already loaded"
fi

#Check if a project is selected
if [ -z "$project"  ]; then
  echo "No project selected! Please add a Project in your local site.conf."
  exit
fi

#check if project env is present
if [ -d "site-config/${project}.env" ]; then
   echo "Please copy the tempalte from ${project} and put it in the site-config folder"
fi

echo "All prerequisites are met!"
=======
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
>>>>>>> version-1
