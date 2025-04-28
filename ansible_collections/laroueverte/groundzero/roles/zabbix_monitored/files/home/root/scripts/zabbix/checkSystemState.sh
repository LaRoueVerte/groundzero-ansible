#!/bin/bash
systemctl status | grep -iP "^\s+State:\s+Running" >> /dev/null
echo $?