#!/bin/bash

if [ "$1" == "" ];then
        echo "Usage : $0 directory"
        exit 1;
fi
mountpoint $1 > /dev/null
echo $?