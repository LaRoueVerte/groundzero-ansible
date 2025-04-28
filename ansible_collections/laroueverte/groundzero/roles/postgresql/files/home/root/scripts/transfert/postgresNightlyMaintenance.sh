#!/bin/bash
cd `dirname $0`
. /home/root/scripts/base.sh
showHeader
if [ $1"" == "" ] ; then
        echo "Usage $0 databaseName "
        exit 1
	fi;
DB_NAME=$1

startScript postgresNightlyMaintenance

testPGDatabase $DB_NAME
testResult

psql -U postgres -d $DB_NAME -c "VACUUM ANALYZE"
testResult

endScript postgresNightlyMaintenance

