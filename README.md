# bridgehead

This repository contains all information and tools to deploy a bridgehead. If you have any questions about deploying a bridgehead, please contact us.

There are some prerequisites, which need to be meet befor starting a bridgehead. If you runnig a Windows or Mac OS maschine you should read starting a bridgehead. If you running a Linux maschine you can do start and install a bridgehead.

## Starting


## Install

Create the dir /src/docker and clone the repository.

The first step is to copy the site.conf file. It contains some configuration and secrets for your bridgehead.

With cp site.dev.conf site.conf you can clone the template. You need to set the project accoriding to the which bridgehead you want to start. It's either a GBN/BBMRI-ERIC, DKTK or C4 Bridgehead.

In this file you can put important varibales

### DKTK

### GBA/BBMRI-ERIC

### C4

The following vairbales need to be set

C4_SAMPLY_STORE_PASS
C4_CONNECTOR_POSTGRES_PASSWORD


The next step is creating a configuration for your bridghead. We can provide you a configuration git repository for bridgehead, just ask us. When you have a DKTK or C4 Bridgehead you propably need some configuration from us anyways.

git submodule add -f https://"$git_username":"$git_access_token"@code.mitro.dkfz.de/scm/bd/"$site_name_lowercase"-config.git ./site-config

If you want to manage the configuration your self you need to copy a env file from the respective project folder into a site-config folder. 

Step 3 is determind your prefered start method. You can can just start the docker container with start-bridgehead and stop it. Alternatively, we advice to use the install script. This script add a systemd service to your system which starts the bridgehead, it also stops and starts the system in the event of a reboot. Also it contains a service for automatic updating your bridgehead. It will check at 3:00 am if there are any updates and will apply them.

Step 4 is checking your bridgehead.  


