#!/bin/bash

if [[ $1 == "" ]]; then
	echo "Usage : $0 host [user]"
	exit
fi

ANSIBLE_USER=
if [[ $2 != "" ]]; then
	ANSIBLE_USER="-u $2"
fi	

if [ -e /tmp/$1.ansiblecheck ]; then
	echo "Ansible access to $1 is OK (already checked)"
	exit
fi

rm -rf /tmp/$1.ansiblecheck > /dev/null 

./ansible_module.sh $ANSIBLE_USER -m ping $1 > /dev/null
RESULT=$?
if [[ $RESULT != "0" ]]; then
	./ansible_module.sh $ANSIBLE_USER -m ping $1
	echo "Please install python 2/3 on remote host"
	echo "apt-get install python"
	exit
else
	echo "Ansible access to $1 is OK"
	touch /tmp/$1.ansiblecheck
fi

 
