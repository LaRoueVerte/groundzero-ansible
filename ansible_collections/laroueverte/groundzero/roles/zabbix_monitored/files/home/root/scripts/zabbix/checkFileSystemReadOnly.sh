#!/bin/bash

if [ "$1" == "" ];then
        echo "Usage : $0 directory"
        exit 1;
fi

DIRECTORY=$1
touch $DIRECTORY/test_read_only.file >/dev/null 2>&1 && rm $DIRECTORY/test_read_only.file > /dev/null 2>&1
RES=$?
echo $RES
exit $RES
