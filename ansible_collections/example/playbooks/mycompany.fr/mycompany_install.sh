
./ansible_check.sh mycompany.fr   
./ansible.sh ./playbooks/mycompany.fr/mycompany_install.yml -e  "@~/mycompany.vault" --ask-vault-pass "$@" 

