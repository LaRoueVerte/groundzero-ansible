#!/bin/bash
cd `dirname $0`
. /home/root/scripts/base.sh
if [ $1"" == "" ] ; then
        echo "Usage $0 raidDevice"
        echo "      where raidDevice is something like /dev/md1"
        exit 1
        fi;
RAIDDEVICE=$1

MDADM=`mdadm -D $RAIDDEVICE`
testResult

OUTPUT=`mdadm -D $RAIDDEVICE | egrep "^[[:space:]]+State" | sed -r "s/^[[:space:]]+State[[:space:]]+\:[[:space:]]+(.*)$/\1/" 2>&1 `
testResult

echo $OUTPUT
