#!/bin/bash
cd

. /home/root/scripts/base.sh

INSTALL_DB=NO
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
	elif [[ $1 == "--remotefolder" ]] ; then
	   REMOTE_FOLDER=$2
	   shift
	   shift
   	elif	[[ $1 == "--install-db" ]] ; then
	   INSTALL_DB=YES
	   shift
	else
	   echo "Unknown option $1";
	   exit;
	fi
done

REMOTE_FOLDER=/home/transfert/$DB_NAME/replicateFromRecipient
LOCAL_FOLDER=$REMOTE_FOLDER

if [ $DB_NAME"" == "" ] || [ $SERVER"" == "" ] ; then
        echo "Usage $0 --dbname databaseName --server remoteServer [--pgdumpoptions pgDumpOptions] [--install-db]"
        exit 1
fi

RUNNINGUSER=`whoami`

if [[ ! "$RUNNINGUSER" == "transfert" ]]; then
	echo "This script must be called using transfert user"
	exit 1
fi

TIMESTAMP_HOUR=`date +%H`
BACKUP_NAME=replicateFromRecipient$TIMESTAMP_HOUR

TIMESTAMP=`date  +%Y-%m-%d-%H`
TIMESTAMP_DAY=`date  +%Y-%m-%d-20`

FILENAME=backup_recipient_$DB_NAME-$TIMESTAMP.sql

cd

#creation du dossier local si necessaire
mkdir -p $LOCAL_FOLDER
testResult

#creation du dossier remote si necessaire
ssh transfert@$SERVER mkdir -p $REMOTE_FOLDER
testResult

#Backup de la base en remote
ssh transfert@$SERVER /home/root/scripts/transfert/backupPostgres.sh $DB_NAME $REMOTE_FOLDER $FILENAME "$PG_DUMP_OPTIONS"
testResult

#Compression des fichiers non compressés
ssh transfert@$SERVER nice pigz -p 4 -f $REMOTE_FOLDER/*.sql
testResult

#On Télécharge le fichier en local
scp transfert@$SERVER:$REMOTE_FOLDER/$FILENAME.gz $LOCAL_FOLDER/$FILENAME.gz 
testResult

if [ $INSTALL_DB == "YES"  ]; then
	#On droppe et recrée la base en local (non exécuté par sécurité ! )
	echo /home/root/scripts/transfert/createPostgresDatabase.sh $DB_NAME -virgin
	testResult
	
	#On installe la base en local (non exécuté par sécurité ! )
	echo /home/root/scripts/transfert/installPostgresDb.sh $DB_NAME $LOCAL_FOLDER/$FILENAME.gz
	testResult
fi	
