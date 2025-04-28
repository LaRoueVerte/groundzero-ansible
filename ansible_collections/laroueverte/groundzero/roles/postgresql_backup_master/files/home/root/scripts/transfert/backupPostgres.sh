#!/bin/bash
cd
. /home/root/scripts/base.sh
showHeader
if [ $1"" == "" ] || [ $2"" == "" ] || [ $3"" == "" ]; then
	echo "Usage $0 databaseName destFolder fileName [pgDumpOptions]"
	echo "Ex: ./backupPostgres.sh livi /tmp test.sql \"-T livi_directionscache\""
	exit 1
fi;
DB_NAME=$1
FOLDER=$2
FILE=$3
PG_DUMP_OPTIONS=""

if [ ! -z "$4" ]; then
	PG_DUMP_OPTIONS=$4
fi;

if [ ! -e $2"" ]; then
	echo "Le dossier $2 n'existe pas!!!";
	exit 2
fi;

testPGDatabase $DB_NAME
testResult

FULL_FILENAME=$FOLDER/$FILE

rm -rf $FULL_FILENAME
testResult

pg_dump -U postgres $PG_DUMP_OPTIONS $DB_NAME > $FULL_FILENAME
testResult

