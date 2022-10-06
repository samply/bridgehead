#!/bin/bash

source lib/log.sh

function hc_set_uuid(){
    HCUUID="$1"
}

function hc_set_service(){
    HCSERVICE="$1"
}

UPTIME=

function hc_send(){
    if [ -n "$MONITOR_APIKEY" ]; then
        hc_set_uuid $MONITOR_APIKEY
    fi

    if [ -n "$HCSERVICE" ]; then
        HCURL="https://hc-ping.com/$PING_KEY/$HCSERVICE"
    fi
    if [ -n "$HCUUID" ]; then
        HCURL="https://hc-ping.com/$HCUUID"
    fi
    if [ ! -n "$HCURL" ]; then
        log WARN "Healthcheck reporting failed: Neither Healthcheck UUID nor service set - please check config in /etc/bridgehead"
        return 1
    fi

    if [ -z "$UPTIME" ]; then
        UPTIME=$(docker ps --format '{{.Names}} {{.RunningFor}}' --filter name=bridgehead || echo "Unable to get docker statistics")
        UPTIME=$(echo "$UPTIME" | tr '\n' '|' || echo "Unable to get docker statistics")
    fi

    if [ -n "$MSG" ]; then
        MSG="$2\n\nDocker stats: $UPTIME"
        echo -e "$MSG" | curl -s -o /dev/null -X POST --data-binary @- "$HCURL"/"$1" || log WARN "Monitoring failed: Unable to send data to $HCURL/$1"
    else
        curl -s -o /dev/null "$HCURL"/"$1" || log WARN "Monitoring failed: Unable to send data to $HCURL/$1"
    fi
}
