#!/bin/bash
cd `dirname $0`
. ../base.sh
if [[ $1"" == "" ]] || [[ $2"" == "" ]] || [[ $3"" == "" ]] || [[ $4"" == "" ]]; then
        echo "Usage $0 port mbean attribute property"
        exit 1
fi;
PORT=$1
MBEAN=${2/REALCOMMA/,}
MBEAN=${MBEAN/REALCOMMA/,}
MBEAN=${MBEAN/REALCOMMA/,}
MBEAN=${MBEAN/REALCOMMA/,}
MBEAN=${MBEAN/REALCOMMA/,}
MBEAN=${MBEAN/REALCOMMA/,}
MBEAN=${MBEAN/REALCOMMA/,}
MBEAN=${MBEAN/REALCOMMA/,}
MBEAN=${MBEAN/REALCOMMA/,}
MBEAN=${MBEAN/REALDBLQUOTE/\"}
MBEAN=${MBEAN/REALDBLQUOTE/\"}
ATTRIBUTE=$3
PROPERTY=$4

java -jar /home/root/scripts/zabbix/cmdline-jmxclient-0.10.3.jar - localhost:$PORT $MBEAN $ATTRIBUTE 2>&1 | grep $PROPERTY | sed -r "s/.*$PROPERTY: (.*)/\1/"
