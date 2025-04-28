#!/bin/bash

apt list --upgradable 2>/dev/null | grep -v "Listing" | grep -v "En train de lister" | wc -l