#!/bin/bash
cd

. /home/root/scripts/base.sh
showHeader
if [ $1"" == "" ] || [ $2"" == "" ] || [ $3"" == "" ]; then
        echo "Usage $0 databaseName localFolder nbRtention [rsyncDest?]"
        exit 1
fi

RUNNINGUSER=`whoami`

if [[ ! "$RUNNINGUSER" == "transfert" ]]; then
	echo "This script must be called using transfert user"
	exit 1
fi

DB_NAME=$1
LOCAL_FOLDER=$2
NB_KEEP=$3
RSYNC_DEST=$4

LOCAL_FOLDER_DAILY=$LOCAL_FOLDER/daily
LOCAL_FOLDER_HOURLY=$LOCAL_FOLDER/hourly
#Keep start date of the script
TIMESTAMP_HOUR=`date +%H`
BACKUP_NAME=replicationPostgresDB$TIMESTAMP_HOUR

testPGDatabase $DB_NAME
testResult

TIMESTAMP=`date  +%Y-%m-%d-%H`
TIMESTAMP_DAY=`date  +%Y-%m-%d-20`

FILENAME=backup_$DB_NAME-$TIMESTAMP.sql

cd

#creation du folder hourly si necessaire
mkdir -p $LOCAL_FOLDER_HOURLY
testResult

#Backup de la base
/home/root/scripts/transfert/backupPostgres.sh $DB_NAME $LOCAL_FOLDER $FILENAME
testResult

#Compression des fichiers non compréssés
nice pigz -p 5 -f $LOCAL_FOLDER/*.sql
testResult

#Si on est a la timestamp du backup par jour
if [ $TIMESTAMP == $TIMESTAMP_DAY  ]; then
	mkdir -p $LOCAL_FOLDER_DAILY
	testResult

	cp $LOCAL_FOLDER/$FILENAME.gz $LOCAL_FOLDER_DAILY
	testResult

	##On garde les N recents en local
	/home/root/scripts/keepRecent/keepRecent.sh $LOCAL_FOLDER_DAILY $NB_KEEP backup .sql.gz
	testResult

fi

# on copie dans hourly
cp $LOCAL_FOLDER/$FILENAME.gz $LOCAL_FOLDER_HOURLY
testResult

#On garde les N recents en local
/home/root/scripts/keepRecent/keepRecent.sh $LOCAL_FOLDER $NB_KEEP backup .sql.gz
testResult

#On garde les N recents dans hourly
/home/root/scripts/keepRecent/keepRecent.sh $LOCAL_FOLDER_HOURLY $NB_KEEP backup .sql.gz
testResult

if [[ ! "$RSYNC_DEST" == "" ]]; then
	ionice -c3 rsync -vaz --delete $LOCAL_FOLDER $RSYNC_DEST
fi
