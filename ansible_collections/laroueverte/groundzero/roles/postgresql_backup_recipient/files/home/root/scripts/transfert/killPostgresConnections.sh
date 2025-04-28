#!/bin/bash
cd `dirname $0`
. /home/root/scripts/base.sh
showHeader
if [ $1"" == "" ]; then
        echo "Usage $0 databaseName"
	exit 1
fi;

DB_NAME=$1

testPGDatabase $DB_NAME
testResult

psql -U postgres -c "select pg_terminate_backend(pid) from pg_stat_activity where datname = '$DB_NAME'"
testResult
