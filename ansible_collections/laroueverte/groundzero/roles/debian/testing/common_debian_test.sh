export ANSIBLE_ROLES_PATH=`dirname $0`/../../../roles
export ANSIBLE_ROLES_PATH=`readlink -f $ANSIBLE_ROLES_PATH`

ansible-playbook -i ./test/ansible_hosts -i./roles/common_debian/testing/ansible_hosts --private-key ./test/key/client  -u root ./roles/common_debian/testing/common_debian_test.yml "$@"
