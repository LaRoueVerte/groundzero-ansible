#!/bin/bash

if [ "$1" == "" ];then
        echo "Usage : $0 dnsServerAddres"
        exit 1;
fi
dig +tries=1 +time=1 @$1 $2
RES=$?
echo $RES
exit $RES