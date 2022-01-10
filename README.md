# bridgehead

This repository contains all information and tools to deploy a bridgehead. If you have any questions about deploying a bridgehead, please contact us.

There are some prerequisites, which need to be meet befor starting a bridgehead. If you runnig a Windows or Mac OS maschine you should read starting a bridgehead. If you running a Linux maschine you can start or install a bridgehead.


## Setup

Clone this repository to /srv/docker

The first step is to copy the site.conf . It contains some configuration and secrets for your bridgehead.

With cp site.dev.conf site.conf you can clone the template. You need to set the project accoriding to the which bridgehead you want to start. It's either a GBN/BBMRI-ERIC, DKTK or C4 Bridgehead.

Each Project needs it own .env file where all the settings are located. Each Project has a template for it in there respective folder. We offer you to setup the file with and also to manage it.


### DKTK

For DKTK set in the site.conf the project to "dkkt". Also you need to set many settings in the env file. For the API keys for the psuenomisation you need to contact the Mainzelliste Team. 

### GBA/BBMRI-ERIC

For an GBN/BBMRI-ERIC deployment set the project to gbn. When you already deployed a bridgehead you can reuse the env file for it.

### C4

For C4 project it is similar to DKTK. Set the ldm_base_url in the configuration table to null.

### Git repository

If you already have a git config repositpory you can clone it with 

git submodule add -f https://"$git_username":"$git_access_token"@code.mitro.dkfz.de/scm/bd/"$site_name_lowercase"-config.git ./site-config

## Starting your bridgehead

There two methods to start the bridgehead. For Windows, Linux and Mac OS you can use the start-bridgehead.sh to deploy it wit docker-compose. If will also check some other setting of your system.

The second methods is using the systemd management tool you start, stop and update your bridgehead.

Just run the install-bridgehead and thats it.

