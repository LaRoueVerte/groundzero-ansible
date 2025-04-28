#!/bin/bash

function usage() {
	echo "Get all errors from apache logs"
	echo "Usage $0 [--filter ] logs... "
	echo "	      --filter : grep -E expression to filter out logs"
	echo "        logs : 1 or more log file to analyze"
	echo " Example : "
	echo " All errors on /companion/ urls : "
	echo "/home/root/scripts/getApacheErrors.sh --filter "/companion/" /var/log/apache2/vlogs/all.80/access-2024-05-2?.log"
}

FILTER="."
if [[ "$1" == "--filter" ]] ; then
	shift
	if [[ "$1" == "" ]] ; then
		echo "Error : missing argument for filter"
		usage
		exit
	fi
	FILTER=$1
	shift
fi

ANTI_FILTER="this_pattern_is_not_found_so_its_easier_to_anti-filter"
if [[ "$1" == "--anti-filter" ]] ; then
	shift
	if [[ "$1" == "" ]] ; then
		echo "Error : missing argument for filter"
		usage
		exit
	fi
	ANTI_FILTER=$1
	shift
fi

if [[ "$1" == "" ]] ; then
	usage
	exit
fi

echo "Using FILTER=$FILTER ANTI_FILTER=$ANTI_FILTER FILES="
echo "$@"

grep -E "$FILTER" "$@" | grep -Ev "$ANTI_FILTER" | sed -E -e 's/^[^"]*"([^ ]*) ([^ ]*)[^"]*" ([^ ]*) .*/O=\1 U=\2 S=\3/g' | grep -E "S=(40.|50.)" | sort -u
