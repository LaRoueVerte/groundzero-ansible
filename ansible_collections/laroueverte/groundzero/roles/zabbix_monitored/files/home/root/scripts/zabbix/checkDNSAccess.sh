#!/bin/bash

dig +tries=1 +time=1 ovh.com | grep 198.27.92.1 > /dev/null
RES=$?
echo $RES
exit $RES