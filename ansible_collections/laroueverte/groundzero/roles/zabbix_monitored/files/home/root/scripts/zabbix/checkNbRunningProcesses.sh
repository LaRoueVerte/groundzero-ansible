#!/bin/bash

if [ $# -ne 0 ];then
        echo "Usage : $0 "
        exit 1;
fi
grep running /proc/*/status 2>/dev/null | wc -l