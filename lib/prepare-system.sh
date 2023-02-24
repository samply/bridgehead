#!/bin/bash -e

source lib/log.sh
source lib/functions.sh

log "INFO" "Preparing your system for bridgehead installation ..."

# Check, if running in WSL
if [[ $(grep -i Microsoft /proc/version) ]]; then
    # Check, if systemd is available
    if [ "$(systemctl is-system-running)" = "offline" ]; then
        log "ERROR" "It seems you have no active systemd environment in your WSL environment. Please follow the guide in https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/"
        exit 1
    fi
fi

# Create the bridgehead user
if id bridgehead &>/dev/null; then
    log "INFO" "Existing user with id $(id -u bridgehead) will be used by the bridgehead system units."
else
    log "INFO" "Now creating a system user to own the bridgehead's files."
    useradd -M -g docker -N bridgehead || fail_and_report ""
fi

# Clone the OpenSource repository of bridgehead
bridgehead_repository_url="https://github.com/samply/bridgehead.git"
if [ -d "/srv/docker/bridgehead" ]; then
    current_owner=$(stat -c '%U' /srv/docker/bridgehead)
    if [ "$(su -c 'git -C /srv/docker/bridgehead remote get-url origin' $current_owner)" == "$bridgehead_repository_url" ]; then
        log "INFO" "Bridgehead's open-source repository has been found at /srv/docker/bridgehead"
    else
        log "ERROR" "The directory /srv/docker/bridgehead seems to exist, but doesn't contain a clone of $bridgehead_repository_url\nPlease delete the directory and try again."
        exit 1
    fi
else
    log "INFO" "Cloning $bridgehead_repository_url to /srv/docker/bridgehead"
    mkdir -p /srv/docker/
    git clone bridgehead_repository_url /srv/docker/bridgehead
fi

case "$PROJECT" in
	ccp)
		site_configuration_repository_middle="git.verbis.dkfz.de/bridgehead-configurations/bridgehead-config-"
		;;
	bbmri)
		site_configuration_repository_middle="git.verbis.dkfz.de/bbmri-bridgehead-configs/"
		;;
	*)
		log ERROR "Internal error, this should not happen."
        exit 1
		;;
esac

# Clone the site-configuration
if [ -d /etc/bridgehead ]; then
    current_owner=$(stat -c '%U' /etc/bridgehead)
    if [ "$(su -c 'git -C /etc/bridgehead remote get-url origin' $current_owner | grep $site_configuration_repository_middle)" ]; then
        log "INFO" "Your site config repository in /etc/bridgehead seems to be installed correctly."
    else
        log "WARN" "Your site configuration repository in /etc/bridgehead seems to have another origin than git.verbis.dkfz.de. Please check if the repository is correctly cloned!"
    fi
else
    log "INFO" "Now cloning your site configuration repository for you."
    read -p "Please enter your site: " site
    read -s -p "Please enter the bridgehead's access token for your site configuration repository (will not be echoed): " access_token
    site_configuration_repository_url="https://bytoken:${access_token}@${site_configuration_repository_middle}$(echo $site | tr '[:upper:]' '[:lower:]').git"
    git clone $site_configuration_repository_url /etc/bridgehead
    if [ $? -gt 0 ]; then
        log "ERROR" "Unable to clone your configuration repository. Please obtain correct access data and try again."
    fi
fi

chown -R bridgehead /etc/bridgehead /srv/docker/bridgehead

log INFO "System preparation is completed and private key is present."

