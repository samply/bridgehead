# bridgehead

This repository contains all tools to deploy a bridgehead with docker. If you have any questions about deploying a bridgehead, please contact us.

There are some prerequisites, which need to be meet before starting a bridgehead. If you running a Windows or Mac OS machine you should read starting a bridgehead. If you running a Linux machine you can start or install a bridgehead.


## Setup

Clone this repository to /srv/docker/

The first step is to copy the site.conf. It contains some configuration and secrets for your bridgehead.

With cp site.dev.conf site.conf you can clone the template. You need to set the project accoriding to the which bridgehead you want to start. It's either a GBN/BBMRI-ERIC, DKTK, DKTK-FED or C4 Bridgehead.

Each Project needs a .env file where all the settings are located. Each Project has a template for it in their respective folder. We offer you to setup the file with and also to manage it.

### Git repository

If you already have a git config repository you can clone it with 

git submodule add -f https://"$git_username":"$git_access_token"@code.mitro.dkfz.de/scm/bd/"$site_name_lowercase"-config.git ./site-config

### DKTK

For DKTK set in the site.conf the project to "dkkt". Also, you need to set many settings in the env file. For the API keys you need to contact the Mainzelliste Team. 

### DKTK-FED

For the DKTK Federate Search put dkkt-fed in the site.conf.

### GBA/BBMRI-ERIC

Coming soon

### C4

Coming soon


## Starting your bridgehead

There two methods to start the bridgehead. For Windows, Linux and Mac OS you can use the start-bridgehead.sh to start it with docker-compose.
The second methods is using the systemd management tool you start, stop and update your bridgehead.
