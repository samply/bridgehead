function teilerSetup() {
	if [ -n "$ENABLE_TEILER" ];then
		log INFO "Teiler setup detected -- will start Teiler service."
		OVERRIDE+=" -f ./$PROJECT/modules/teiler-compose.yml"
	fi
	# TODO: Generate password in another way so that not all passwords are the same?
	TEILER_DB_PASSWORD="$(echo \"This is a salt string to generate one consistent password. It is not required to be secret.\" | openssl rsautl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
}
