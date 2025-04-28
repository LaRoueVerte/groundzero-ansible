#!/bin/bash

# Checks addok updatable packages. 
# Avoids falcon and unidecode that seems to be pinned to a specific version by addok
bash -c "source /etc/addok/venv/bin/activate && pip list -o --format freeze 2>&1 | grep -v DEPRECATION | grep -i 'addok\|pip' > /dev/null"
RES=$?
if [[ $RES == "1" ]]; then
	echo "OK";
else 
	echo "NEEDSUPDATE";
fi 
