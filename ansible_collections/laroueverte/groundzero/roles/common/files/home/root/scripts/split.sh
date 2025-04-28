#!/bin/bash
function usage() {
        echo "Usage : $0 file nbParts"
        echo "     file is the file to be split"
        echo "     nbParts is the number of parts to split the file into"
}

if [[ ${1} = '' ]] || [[ ${2} = '' ]]; then
        usage
        exit 1;
fi

a=`wc -c < $1`
part=$((a / $2))
split --bytes $part $1 $1-part-
