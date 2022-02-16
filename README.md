# bridgehead

This repository contains all tools to deploy a bridgehead with docker. If you have any questions about deploying a bridgehead, please contact us.

There are some prerequisites, which need to be meet before starting a bridgehead. If you running a Windows or Mac OS machine you should read starting a bridgehead. If you running a Linux machine you can start or install a bridgehead.

## Setup

Clone this repository to /srv/docker/

The first step is to copy the site.conf. It contains some configuration and secrets for your bridgehead.

With cp site.dev.conf site.conf you can clone the template. You need to set the project accoriding to the which bridgehead you want to start. It's either a GBN/BBMRI-ERIC, DKTK, DKTK-FED or C4 Bridgehead.

Each Project needs a .env file where all the settings are located. Each Project has a template for it in their respective folder. We offer you to setup the file with and also to manage it.

### DKTK-FED

For the DKTK Federate Search put dkkt-fed as project in the site.conf.

## Starting the bridgehead

./install_bridgehead