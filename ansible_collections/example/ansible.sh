#!/bin/bash
if [[ $1 == "" ]]; then
	echo "Usage : $0 playbook [ansible_options]"
	exit
fi

PLAYBOOK=$1
shift

LRV_ROLES=`dirname $0`/roles
LRV_ROLES=`readlink -f $LRV_ROLES`

# Install the groundzero-ansible collection using ansible-galaxy
# Or uncomment below to use the local version
# GZ_ROLES=`dirname $0`/../../groundzero-ansible
# GZ_ROLES=`readlink -f $GZ_ROLES`

ANSIBLE_ROLES_PATH="$LRV_ROLES"
export ANSIBLE_ROLES_PATH

export ANSIBLE_COLLECTIONS_PATHS="$GZ_ROLES"
echo $ANSIBLE_COLLECTIONS_PATHS
ansible-playbook -i ansible_hosts -u root $PLAYBOOK "$@"
