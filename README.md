# groundzero-ansible

## Warning
All former laroueverte ansible scripts to install and manage servers using Debian. Some roles have not been tested after open sourcing :
- addokserver
- ansible
- cifs_backup_client
- docker
- mariadb
- openvpn
- postgresql_backup_master
- postgresql_backup_recipient
- reboot_protection
- tomcat
- tomcat_deploy
- zabbix_monitored
- zabbix
These roles were production ready and may need slight modifications to run.

Some things may be hardcoded, not documented or may install stuff not relevant for the community. This repository can evolve depending of your needs. All PRs, issues and comments are welcomed !

All other roles have been tested on a fresh install

## Usage
### Install the collection using ansible-galaxy
Add instructions here

### How to use roles
All roles are documented in main.yml. Install from https://laroueverte.github.io/groundzero-ansible/ using ansible-galaxy : 
```sh
ansible-galaxy collection install git+https://github.com/laroueverte/groundzero-ansible#/ansible_collections/laroueverte/groundzero,release
```

## Variables
We are using a host inventory to store IP addresses as we do not rely on remote host inventory (thus, playbook will run even if other side is down or unavailable). Each name into "hostdata" must contain an "ip" field. All hosts will be referenced.

```yml
hostsdata:
  myhost.mycompany.net:
    ip: 42.42.42.42
```

## Example
A full running example inspired from real life is provided into example directory. See it at https://github.com/LaRoueVerte/groundzero-ansible/tree/release/ansible_collections/example
