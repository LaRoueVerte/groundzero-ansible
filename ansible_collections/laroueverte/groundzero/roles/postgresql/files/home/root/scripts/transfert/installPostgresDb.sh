#!/bin/bash
cd `dirname $0`
. /home/root/scripts/base.sh
showHeader
if [ $1"" == "" ] || [ $2"" == "" ] ; then
        echo "Usage $0 databaseName localFile"
	exit 1
fi;

FILE=$2
DB_NAME=$1

testExistFichier $FILE
testResult

testPGDatabase $DB_NAME
testResult

nice unpigz -p 5 -c $FILE | psql -U postgres $DB_NAME
psql -U postgres -d $DB_NAME -c "VACUUM ANALYZE"

