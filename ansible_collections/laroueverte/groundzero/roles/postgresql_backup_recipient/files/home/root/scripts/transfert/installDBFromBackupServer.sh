#!/bin/bash
cd
. /home/root/scripts/base.sh
showHeader

while [[ $1 != "" ]]; do
	if [[ $1 == "--dbname" ]] ; then
	   DB_NAME=$2
	   shift
	   shift
	fi
	if [[ $1 == "--backupserver" ]] ; then
	   BACKUP_SERVER=$2
	   shift
	   shift
	fi
	if [[ $1 == "--backupfilepath" ]] ; then
	   BACKUP_FILE_PATH=$2
	   shift
	   shift
	fi
done

if [ $DB_NAME"" == "" ] || [ $BACKUP_SERVER"" == "" ] || [ $BACKUP_FILE_PATH"" == "" ]; then
        echo "Usage $0 --dbname databaseName --backupserver backupserver --backupfilepath backupfilepath"
        exit 1
fi

# Drop local instance
/home/root/scripts/transfert/createPostgresDatabase.sh $DB_NAME -virgin

ssh transfert@$BACKUP_SERVER gunzip -c $BACKUP_FILE_PATH | psql -U postgres $DB_NAME
