#!/bin/bash
cd `dirname $0`
. /home/root/scripts/base.sh

if [[ "$1" == "" ]] || [[ "$2" == "" ]] || [[ "$3" == "" ]] ; then
        echo "Usage : $0 trapper srcFolder destFolder [other rsync options]";
        echo "           trapper : if defined to "NONE", does not send trapper. Else sends to zabbix"
        exit
fi

SCRIPT_TRAPPER=$1
SRC_FOLDER=$2
DEST_FOLDER=$3
DATE=`date  +%Y-%m-%d\ %H\:%M\:%S`
shift
shift
shift

echo '----- Backup at '$DATE
if [[ "$SCRIPT_TRAPPER" != "NONE" ]]; then
	startScript $SCRIPT_TRAPPER
fi

rsync -vaz --delete "$@" $SRC_FOLDER $DEST_FOLDER

if [[ "$SCRIPT_TRAPPER" != "NONE" ]]; then
	endScript $SCRIPT_TRAPPER
fi
