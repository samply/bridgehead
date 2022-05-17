#!/bin/bash -e
log() {
  echo -e "$(date +'%Y-%m-%d %T')" "$1:" "$2"
}

generatePackageInstallCommand () {
  # see: https://unix.stackexchange.com/a/571192
  if [ -x "$(command -v apk)" ]; then
    echo "apk add --no-cache $1"
  elif [ -x "$(command -v apt-get)" ]; then
    echo "apt-get install -y $1"
  elif [ -x "$(command -v yum)" ]; then
    echo "yum install -y $1"
  elif [ -x "$(command -v dnf)" ]; then
    echo "dnf install -y $1"
  else
    log "ERROR" "Couldn't detect package manager automatically. Please install package $1 manually.";
    exit 1;
  fi
}

if [ "$EUID" -ne 0 ]; then
    log "ERROR" "Please run as root"
    exit 1
fi

log "INFO" "Welcome to the Bridgehead System Preparation script.\nThis script will setup your system for installing a bridgehead."

log "INFO" "Checking if all necessary programms are installed ..."

# 1. Install Git
# TODO: which produces unwanted output!
if [ "$(which git)" ]; then
    log "INFO" "Git is already installed in version $(git --version)"
else
    log "INFO" "Git is not installed. We will try to install it for you."
    git_install_command=$(generatePackageInstallCommand "git")
    log "INFO" "Now printing a preview of the necessary commands to install git:"
    echo "$git_install_command";
    read -p "Should we continue with the installation of git? (Y/y/N/n)" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        "$($git_install_command)"
        # TODO: fails even on successfull install (yum) ...
        if [ $? -gt 0 ]; then
            log "ERROR" "Installation of git didn't finish sucessfully. Aborting installation ..."
            exit 1;
        fi
        if [ "$http_proxy" != "" ]; then
            # TODO: Proxy Configuration for Git for user bridgehead
        fi
    else
        log "ERROR" "Didn't install git.\nTo proceed with the installation please install git manually."
        log "More details about the installation of git are available here: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git"
        exit 1;
    fi
fi

# 2. Install Docker and Docker Compose
if [ "$(which docker)" ]; then
    log "INFO" "Docker is already installed in version $(docker --version)"
else
    log "INFO" "Docker is not installed. We will try to install it for you."
    curl -fsSL https://get.docker.com -o get-docker.sh
    if [ $? -gt 0 ]; then
       log "ERROR" "Couldn't download docker installation script.\nPlease ensure you have write permission to this directory and curl is using the correct proxy settings."
    fi
    log "INFO" "Now printing a preview of all necessary commands to install docker:"
    DRY_RUN=1 sh ./get-docker.sh
    read -p "Should we continue with the installation of docker? (Y/y/N/n)" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sh ./get-docker.sh
        # TODO: fails even on successfull install ...
        if [ $? -gt 0 ]; then
            log "ERROR" "Installation of docker didn't finish sucessfully. Aborting installation ..."
            exit 1;
        fi
        # TODO: Proxy Configuration for Docker
        if [ "$http_proxy" != "" ]; then
            cat << EOF > /etc/systemd/system/docker.service.d/proxy.conf
            # TODO: Not working at the moment ...
            cat << EOF > ~/test-proxy.conf
               # This config was automatically written by prepare-bridgehead-system.sh on $(date)
               [Service]
               Environment=HTTP_PROXY=$http_proxy
               Environment=HTTPS_PROXY=$https_proxy
               Environment=FTP_PROXY=$ftp_proxy
               EOF;
        fi
    else
        log "ERROR" "Didn't install docker.\nTo proceed with the installation please manually install docker and docker-compose."
        log "More details about the installation of docker is available here: https://docs.docker.com/engine/install"
        log "More details about the installation of docker-compose is available here: https://docs.docker.com/compose/install/#install-compose-on-linux-systems"
        exit 1;
    fi
fi

# 3. Create the bridgehead user
if id bridgehead &>/dev/null; then
    log "INFO" "Detected user bridgehead with id $(id -u bridgehead). This user will be used by the bridgehead system units."
else
    log "INFO" "Now creating a user for running the bridgehead"
    if [ "$(which adduser)" ]; then
        log "INFO" "Detected adduser command. We will now create the user using this command!"
        # TODO: --disabled-login not available on centos, fallback to useradd?
        echo "adduser --no-create-home --disabled-login --ingroup docker --gecos \"\" bridgehead;"
        adduser --no-create-home --disabled-login --ingroup docker --gecos "" bridgehead;
    elif ["$(which useradd)"]; then
        log "INFO" "Detected useradd command. We will now create the user using following command!"
        echo "useradd -M -g docker -N -s /sbin/nologin bridgehead"
        useradd -M -g docker -N -s /sbin/nologin bridgehead
    else
        log "ERROR" "Couldn't automatically create a bridgehead user. Please refer to the readme and create it manually"
        exit 1
    fi
fi

# 4. Clone the OpenSource repository of bridgehead
bridgehead_repository_url="https://github.com/samply/bridgehead.git"
if [ -d "/srv/docker/bridgehead" ]; then
    if [ "$(git -C /srv/docker/bridgehead remote get-url origin)" == "$bridgehead_repository_url" ]; then
        log "INFO" "Bridgeheads OpenSource Repository is already cloned"
    else
        log "ERROR" "The directory /srv/docker/bridgehead seems to exist, but doesn't contain a clone of $bridgehead_repository_url\nPlease move the contents of this directory to another place."
        exit 1
    fi
else
    log "INFO" "Cloning https://github.com/samply/bridgehead.git to /srv/docker/bridgehead"
    mkdir -p /srv/docker/;
    git clone https://github.com/samply/bridgehead.git /srv/docker/bridgehead;
    chown -R bridgehead /srv/docker/bridgehead;
fi

# 5. Clone the site-configuration
log "INFO" "We will now check if your sites configuration repository is already cloned ..."
if [ -d "/etc/bridgehead" ]; then
    if [ "$(git -C /etc/bridgehead remote get-url origin | grep "git.verbis.dkfz.de")" ]; then
        log "INFO" "Your sites config repository in /etc/bridgehead seems to be installed correctly."
    else
        log "WARN" "Your sites configuration repository in /etc/bridgehead seems to have another origin than git.verbis.dkfz.de. Please check if the repository is correctly cloned!"
    fi
else
    read -p "Please enter your site: "
    site=$REPLY
    read -p "Please enter your gitlab user email: "
    email=${REPLY/@/%40}
    read -p "Please enter an access_token for gitlab. You can create it in your gitlab profile: "
    access_token=$REPLY
    log "INFO" "Now cloning your sites configuration repository for you."
    site_configuration_repository_url="https://$email:$access_token@git.verbis.dkfz.de/bridgehead-configurations/bridgehead-config-$(echo $site | tr '[:upper:]' '[:lower:]').git"
    log "The following command will be executed: git clone $site_configuration_repository_url /etc/bridgehead"
    git clone $site_configuration_repository_url /etc/bridgehead
    if [ $? -gt 0 ]; then
        log "ERROR" "Couldn't clone your configuration repository sucessfully. Please manually ensure that the download works."
    fi
    chown -R bridgehead /etc/bridgehead;
fi
