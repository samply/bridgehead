#!/bin/bash

if [ -n "${ENABLE_DNPM_NODE}" ]; then
	log INFO "DNPM setup detected (BwHC Node) -- will start BwHC node."
	OVERRIDE+=" -f ./$PROJECT/modules/dnpm-node-compose.yml"

	# Set variables required for BwHC Node. ZPM_SITE is assumed to be set in /etc/bridgehead/<project>.conf
	DNPM_APPLICATION_SECRET="$(echo \"This is a salt string to generate one consistent password for DNPM. It is not required to be secret.\" | sha1sum | openssl pkeyutl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
	if [ -z "${ZPM_SITE+x}" ]; then
		log ERROR "Mandatory variable ZPM_SITE not defined!"
		exit 1
	fi
	if [ -z "${DNPM_DATA_DIR+x}" ]; then
		log ERROR "Mandatory variable DNPM_DATA_DIR not defined!"
		exit 1
	fi
			if grep -q 'traefik.http.routers.landing.rule=PathPrefix(`/landing`)' /srv/docker/bridgehead/minimal/docker-compose.override.yml 2>/dev/null; then
				echo "Override of landing page url already in place"
			else
				echo "Adding override of landing page url"
				if [ -f /srv/docker/bridgehead/minimal/docker-compose.override.yml ]; then
					echo -e '  landing:\n    labels:\n      - "traefik.http.routers.landing.rule=PathPrefix(`/landing`)"' >> /srv/docker/bridgehead/minimal/docker-compose.override.yml
				else
					echo -e 'version: "3.7"\nservices:\n  landing:\n    labels:\n      - "traefik.http.routers.landing.rule=PathPrefix(`/landing`)"' >> /srv/docker/bridgehead/minimal/docker-compose.override.yml
				fi
			fi
fi
