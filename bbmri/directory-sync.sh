#!/bin/bash

function dirSetup() {
	if [ -n "$DS_DIRECTORY_USER_NAME" ]; then
		log INFO "Directory sync setup detected -- will start directory sync service."
		OVERRIDE+=" -f ./$PROJECT/directory-sync-compose.yml"
	fi
}
