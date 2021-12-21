#!/bin/bash


## Check if user is a su
echo "Welcome to the starting a bridgehead. We will get your instance up and running in no time"
echo "First we will check if all prerequisites are met ..."
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

echo "All prerequisites meet! All systems are ready to go!"
