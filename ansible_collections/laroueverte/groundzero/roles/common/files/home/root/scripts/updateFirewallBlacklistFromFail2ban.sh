#!/bin/bash

grep -iP 'ban [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' /var/log/fail2ban.log | sed -r 's/^.*[b-B]an ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)$/\1/g' | sort -u > /etc/firewall.blacklist.HACKER
cp /etc/firewall.blacklist /etc/firewall.blacklist.`date +%Y%m%d-%H_%M_%S`
cat /etc/firewall.blacklist.HACKER /etc/firewall.blacklist > /etc/firewall.blacklist.ALL
sort -u /etc/firewall.blacklist.ALL > /etc/firewall.blacklist
