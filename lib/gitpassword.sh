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

assertVarsNotEmpty SITE_ID || exit 1

date >> /tmp/gitpass

PARAMS="$(tee -a /tmp/gitpass)"
GITHOST=$(echo "$PARAMS" | grep "^host=" | sed 's/host=\(.*\)/\1/g')

fetchVarsFromVault CCP_GIT

if [ -z "${CCP_GIT}" ]; then
	log ERROR "Git password not found."
	exit 1
fi

tee -a /tmp/gitpass <<EOF
protocol=https
host=$GITHOST
username=bk-${SITE_ID}
password=${CCP_GIT}
EOF

echo >> /tmp/gitpass
