#!/bin/bash
cd `dirname $0`
. /home/root/scripts/base.sh
if [ $1"" == "" ] ; then
        echo "Usage $0 variable [-force]"
        echo "      where variable one of total_accesses,total_kbytes,cpuload,uptime,reqpersec,bytespersec,bytesperreq,busyservers, $idleservers,scoreboard"
        exit 1
        fi;
VARIABLE=$1
FORCE=$2

mkdir -p /tmp/apacheStatus

touch --date="10 mins ago" /tmp/apacheStatus/MIN_RUN
if [ "x$FORCE" = "x-force" ]  || [ ! -e /tmp/apacheStatus/busyservers.out ] || [ /tmp/apacheStatus/MIN_RUN -nt /tmp/apacheStatus/busyservers.out ]; then
        /home/root/scripts/zabbix/parseApache.pl
fi;

cat /tmp/apacheStatus/$VARIABLE.out
