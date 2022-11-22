#!/bin/bash

if [ "$1" != "get" ]; then
	echo "Usage: $0 get"
	exit 1
fi

baseDir() {
	# see https://stackoverflow.com/questions/59895
	SOURCE=${BASH_SOURCE[0]}
	while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
		DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
		SOURCE=$(readlink "$SOURCE")
		[[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
        done
        DIR=$( cd -P "$( dirname "$SOURCE" )/.." >/dev/null 2>&1 && pwd )
        echo $DIR
}

BASE=$(baseDir)
cd $BASE

source lib/functions.sh

assertVarsNotEmpty SITE_ID || fail_and_report 1 "gitpassword.sh failed: SITE_ID is empty."

PARAMS="$(cat)"
GITHOST=$(echo "$PARAMS" | grep "^host=" | sed 's/host=\(.*\)/\1/g')

fetchVarsFromVault GIT_PASSWORD

if [ -z "${GIT_PASSWORD}" ]; then
	fail_and_report 1 "gitpassword.sh failed: Git password not found."
fi

cat <<EOF
protocol=https
host=$GITHOST
username=bk-${SITE_ID}
password=${GIT_PASSWORD}
EOF
