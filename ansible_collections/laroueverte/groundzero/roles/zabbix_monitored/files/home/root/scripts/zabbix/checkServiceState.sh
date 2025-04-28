#!/bin/bash
if [[ $1 = "" ]];then
        echo "Usage : $0 serviceName"
        exit 1;
fi

systemctl status $1 > /dev/null 2>&1
echo $?