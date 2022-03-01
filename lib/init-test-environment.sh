#!/bin/bash
### This configuration file is intended for fast setup of a developers testenvironment.
### The settings made here are normally placed in the system units configuration.
### Refer to the readme on how to do this.
### On long term we want to move those to a zero knowledge passwort manager like bitwarden.

### Configuration for Network Properties
# needed by the connector to resolve hosts address for ui-links and service status checks
export HOSTIP=$(MSYS_NO_PATHCONV=1 docker run --rm --add-host=host.docker.internal:host-gateway ubuntu cat /etc/hosts | grep 'host.docker.internal' | awk '{print $1}');
# needed for the reverse proxy configuration of the services
export HOST=$(hostname)
# additional information about the local proxy if necessary
export HTTP_PROXY_USER=""
export HTTP_PROXY_PASSWORD=""
export HTTPS_PROXY_USER=""
export HTTPS_PROXY_PASSWORD=""

### Configuration for Connector Secrets
# the password of database connector-db
export CONNECTOR_POSTGRES_PASS=pleaseChangeThis1


### Configuration for Samply Store Secrets
# the password of database connector-db
export STORE_POSTGRES_PASS=pleaseChangeThis6

### Configuration for ID-Management Secrets
# the password of database patientlist-db
export ML_DB_PASS=pleaseChangeThis2

# the apikey of the localdatamanagement for the patientlist
export MAGICPL_API_KEY=pleaseChangeThis3
# the apikey of the id-manager for the patientlist
export MAGICPL_MAINZELLISTE_API_KEY=pleaseChangeThis4
# the apikey of the connector for the patientlist
export MAGICPL_API_KEY_CONNECTOR=pleaseChangeThis5

# the apikey of the id-manager for the central patientlist
export MAGICPL_MAINZELLISTE_CENTRAL_API_KEY=dktk[CentralS3cr3tKey]KNE;
# the apikey of the id-manager for the controlnumbergenerator
export MAGICPL_CENTRAL_API_KEY=dguQJ5IoqUrxCF8fNl6fOl2YvsZAVB1Y;
# client-id used for autheticating users in central ccp-authentication service
export MAGICPL_OIDC_CLIENT_ID=bridgehead-developers;
# client-secret used for autheticating users in central ccp-authentication service
export MAGICPL_OIDC_CLIENT_SECRET=1de49kn2j36qom15n7vkrve0g7pgh1f5p7v945pkl2hesak74bgek657tgi6or1hu5ji3m9lfrbhfa0g3haq18ebe205al4uoig9ii5;
