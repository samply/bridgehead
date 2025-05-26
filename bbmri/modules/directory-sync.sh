#!/bin/bash

if [ -n "${DS_DIRECTORY_USER_NAME}" ]; then
	log INFO "Directory sync setup detected -- will start directory sync service."
	OVERRIDE+=" -f ./$PROJECT/modules/directory-sync-compose.yml"
fi
