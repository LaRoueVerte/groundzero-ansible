#!/bin/bash

if [ "$1" == "" ];then
        echo "Usage : $0 processName"
        exit 1;
fi
#for a in ` ls -1 /proc/*/status`; do if [ -e $a ] ; then grep  Name $a; fi | grep $1 ; done | wc -l
ps -ef | grep -- "$1" | grep -v grep | grep -v "$0" | wc -l
