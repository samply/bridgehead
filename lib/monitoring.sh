#!/bin/bash

source lib/log.sh

function hc_set_uuid(){
    HCUUID="$1"
}

function hc_set_service(){
    HCSERVICE="$1"
}

UPTIME=
USER_AGENT=

function hc_send(){
    BASEURL="https://healthchecks.verbis.dkfz.de/ping"
    if [ -n "$MONITOR_APIKEY" ]; then
        hc_set_uuid $MONITOR_APIKEY
    fi

    if [ -n "$HCSERVICE" ]; then
        HCURL="$BASEURL/$PING_KEY/$HCSERVICE"
    fi
    if [ -n "$HCUUID" ]; then
        HCURL="$BASEURL/$HCUUID"
    fi
    if [ ! -n "$HCURL" ]; then
        log WARN "Did not report Healthcheck: Neither Healthcheck UUID nor service set. Please define MONITOR_APIKEY in /etc/bridgehead."
        return 0
    fi

    if [ -z "$UPTIME" ]; then
        UPTIME=$(docker ps -a --format 'table {{.Names}} \t{{.RunningFor}} \t {{.Status}} \t {{.Image}}' --filter name=bridgehead || echo "Unable to get docker statistics")
    fi

    if [ -z "$USER_AGENT" ]; then
        if [ "$USER" != "root" ]; then
            COMMIT_ETC=$(git -C /etc/bridgehead rev-parse HEAD | cut -c -8)
            COMMIT_SRV=$(git -C /srv/docker/bridgehead rev-parse HEAD | cut -c -8)
        else
            COMMIT_ETC=$(su -c 'git -C /etc/bridgehead rev-parse HEAD' bridgehead | cut -c -8)
            COMMIT_SRV=$(su -c 'git -C /srv/docker/bridgehead rev-parse HEAD' bridgehead | cut -c -8)
        fi
        USER_AGENT="srv:$COMMIT_SRV etc:$COMMIT_ETC"
    fi

    if [ -n "$2" ]; then
        MSG="$2\n\nDocker stats:\n$UPTIME"
        echo -e "$MSG" | https_proxy=$SECURE_PROXY curl --max-time 5 -A "$USER_AGENT" -s -o /dev/null -X POST --data-binary @- "$HCURL"/"$1" || log WARN "Monitoring failed: Unable to send data to $HCURL/$1"
    else
        https_proxy=$SECURE_PROXY curl --max-time 5 -A "$USER_AGENT" -s -o /dev/null "$HCURL"/"$1" || log WARN "Monitoring failed: Unable to send data to $HCURL/$1"
    fi
}
