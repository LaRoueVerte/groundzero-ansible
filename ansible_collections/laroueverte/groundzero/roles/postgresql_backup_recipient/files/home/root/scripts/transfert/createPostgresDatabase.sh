#!/bin/bash
cd
. /home/root/scripts/base.sh
showHeader
if [ $1"" == "" ] ; then
        echo "Usage $0 databaseName [-virgin]"
        exit 1
fi;
DB_NAME=$1

/home/root/scripts/transfert/killPostgresConnections.sh $DB_NAME

dropdb -U postgres $DB_NAME
testResult

createdb -U postgres $DB_NAME -E UTF8
testResult

if [ ! "X$2" == "X-virgin" ];then
	createlang -U postgres plpgsql $DB_NAME
	testResult
	
	psql -U postgres -d $DB_NAME -f /usr/share/postgresql/contrib/lwpostgis.sql
	testResult

	psql -U postgres -d $DB_NAME -f /usr/share/postgresql/contrib/spatial_ref_sys.sql
	testResult
	
	psql -U postgres -d $DB_NAME -f /usr/share/postgresql/contrib/btree_gist.sql
	testResult
	
	psql -U postgres -d $DB_NAME -f /usr/share/postgresql/contrib/pg_buffercache.sql
	testResult
fi
