#!/bin/bash
cd

. /home/root/scripts/base.sh

PG_DUMP_OPTIONS=
while [[ $1 != "" ]]; do
	if [[ $1 == "--dbname" ]] ; then
	   DB_NAME=$2
	   shift
	   shift
	elif [[ $1 == "--server" ]] ; then
	   SERVER=$2
	   shift
	   shift
	elif [[ $1 == "--pgdumpoptions" ]] ; then
	   PG_DUMP_OPTIONS=$2
	   shift
	   shift
	else
	   echo "Unknown option $1";
	   exit;
	fi
done

if [ $DB_NAME"" == "" ] || [ $SERVER"" == "" ] ; then
        echo "Usage $0 --dbname databaseName --server remoteServer [--pgdumpoptions pgDumpOptions]"
        exit 1
fi

rm /tmp/data.recipient.txt
TABLENAMES=`ssh transfert@$SERVER "psql -U postgres $DB_NAME -t -A -c \"SELECT table_name FROM information_schema.tables WHERE table_type='BASE TABLE' AND table_schema='public'\""`
for TABLENAME in $TABLENAMES; do
	echo "From recipient : $TABLENAME"
	COUNT=`ssh transfert@$SERVER "psql -U postgres $DB_NAME -t -A -c \"SELECT count(*) from $TABLENAME\""`
	echo "$TABLENAME : $COUNT" >> /tmp/data.recipient.txt
done


rm /tmp/data.master.txt
for TABLENAME in $TABLENAMES; do
	echo "From master : $TABLENAME"
	COUNT=`psql -U postgres $DB_NAME -t -A -c "SELECT count(*) from $TABLENAME"`
	echo "$TABLENAME : $COUNT" >> /tmp/data.master.txt
done

echo vimdiff /tmp/data.recipient.txt /tmp/data.master.txt
