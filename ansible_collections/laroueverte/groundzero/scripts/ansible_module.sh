#!/bin/bash

if [[ $1 = "" ]]; then
	echo "Usage $0 servers ansible_options"
	echo "   servers is a group or a server group from ansible_hosts"
	echo "   useful ansible options :"
	echo "      -m module_name   (for instance -m shell)"
	echo "      -a module_arguments (for instance ls /boot)"
	echo "		-C to check"
	echo " Example : "
	echo "$0 debian -m shell -a 'ls /boot/extlinux/extlinux.conf || /bin/true' -C"
	exit
fi

ansible -i ansible_hosts -u root "$@"
