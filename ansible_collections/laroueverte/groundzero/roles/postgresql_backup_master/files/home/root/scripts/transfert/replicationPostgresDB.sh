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
	if [[ $1 == "--localfolder" ]] ; then
	   LOCAL_FOLDER=$2
	   shift
	   shift
	fi
	if [[ $1 == "--server" ]] ; then
	   SERVER=$2
	   shift
	   shift
	fi
	if [[ $1 == "--nbkeep" ]] ; then
	   NB_KEEP=$2
	   shift
	   shift
	fi
	if [[ $1 == "--rsyncdest" ]] ; then
	   RSYNC_DEST=$2
	   shift
	   shift
	fi
	if [[ $1 == "--pgdumpoptions" ]] ; then
	   PG_DUMP_OPTIONS=$2
	   shift
	   shift
	fi
	if [[ $1 == "--fallbackserver" ]] ; then
	   FALLBACK_SERVER=$2
	   shift
	   shift
	fi
	if [[ $1 == "--remotefolder" ]] ; then
	   REMOTE_FOLDER=$2
	   shift
	   shift
	fi
done

if [ $DB_NAME"" == "" ] || [ $LOCAL_FOLDER"" == "" ] || [ $SERVER"" == "" ] || [ $NB_KEEP"" == "" ]; then
        echo "Usage $0 --dbname databaseName --localfolder localFolder  [--remotefolder remoteFolder] --server remoteServer --nbkeep nbRtention [--rsyncdest rsyncDestination] [--pgdumpoptions pgDumpOptions] [--fallbackserver fallbackserver]"
        exit 1
fi

RUNNINGUSER=`whoami`

if [[ ! "$RUNNINGUSER" == "transfert" ]]; then
	echo "This script must be called using transfert user"
	exit 1
fi

if [[ -z ${REMOTE_FOLDER+x} ]]; then 
	REMOTE_FOLDER=$LOCAL_FOLDER
fi

PS_OUTPUT=`ps -ef | grep -v grep | grep -v cron`
OCC=$(printf "%s\n" "$PS_OUTPUT" | grep "$0" | wc -l)
if [[ $OCC > 2 ]]; then
	echo "Failed to grep $0 into following ps : "
	echo "======================================================================="
	printf "%s\n" "$PS_OUTPUT"
	echo "======================================================================="
	echo "Found $OCC occurrences"
	sendZabbixTrapperValue BackupAlreadyRunningState 1
	exit 1
else
	sendZabbixTrapperValue BackupAlreadyRunningState 0
fi	

LOCAL_FOLDER_DAILY=$LOCAL_FOLDER/daily
LOCAL_FOLDER_HOURLY=$LOCAL_FOLDER/hourly
#Keep start date of the script
startScript replicationPostgresDB
TIMESTAMP_HOUR=`date +%H`
BACKUP_NAME=replicationPostgresDB$TIMESTAMP_HOUR
startScript $BACKUP_NAME

#Statut du script => PENDING ( le pending n'est pas repété par le backupEmpty.sh )
echo 'PENDING' > ~/.BACKUP_STATUS
testPGDatabase $DB_NAME
testResult

TIMESTAMP=`date  +%Y-%m-%d-%H`
TIMESTAMP_DAY_20=`date  +%Y-%m-%d-20`
TIMESTAMP_DAY_21=`date  +%Y-%m-%d-21`

FILENAME=backup_$DB_NAME-$TIMESTAMP.sql

cd

#creation du folder hourly si necessaire
mkdir -p $LOCAL_FOLDER_HOURLY
testResult

#Backup de la base
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Starting backup"
/home/root/scripts/transfert/backupPostgres.sh $DB_NAME $LOCAL_FOLDER $FILENAME "$PG_DUMP_OPTIONS"
testResult
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Finished backup"

#Compression des fichiers non compressés
PIGZ_PROCS=$((`nproc` / 2))
if [ $PIGZ_PROCS == 0 ]; then
	PIGZ_PROCS=1
fi
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Starting compression using ${PIGZ_PROCS} procs"
nice pigz -p ${PIGZ_PROCS} -f $LOCAL_FOLDER/*.sql
testResult
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Finished compression"

#Si on est a la timestamp du backup par jour
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Starting keep recent"
if [ $TIMESTAMP == $TIMESTAMP_DAY_20 ] || [ $TIMESTAMP == $TIMESTAMP_DAY_21 ]; then
	mkdir -p $LOCAL_FOLDER_DAILY
	testResult

	cp $LOCAL_FOLDER/$FILENAME.gz $LOCAL_FOLDER_DAILY
	testResult

	#On garde les N recents en local dans le folder daily
	/home/root/scripts/keepRecent/keepRecent.sh $LOCAL_FOLDER_DAILY $NB_KEEP backup .sql.gz
	testResult

	#On cree le folder en remote
	ssh transfert@$SERVER mkdir -p $REMOTE_FOLDER/daily/
	testResult

	#On Pousse le fichier vers l'autre serveur
	scp $LOCAL_FOLDER_DAILY/$FILENAME.gz transfert@$SERVER:$REMOTE_FOLDER/daily/$FILENAME.gz
	testResult

	#On garde les N recents en remote
	ssh transfert@$SERVER /home/root/scripts/keepRecent/keepRecent.sh $REMOTE_FOLDER/daily/ $NB_KEEP backup .sql.gz
	testResult

fi
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Finished keep recent"

#On Pousse le fichier vers l'autre serveur
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Starting pushing to remote server"
scp $LOCAL_FOLDER/$FILENAME.gz transfert@$SERVER:$REMOTE_FOLDER/$FILENAME.gz
testResult
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Finished pushing to remote server"

#On garde les N recents en remote
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Starting keep recent on remote server"
ssh transfert@$SERVER /home/root/scripts/keepRecent/keepRecent.sh $REMOTE_FOLDER $NB_KEEP backup .sql.gz
testResult

# on déplace dans hourly
mv $LOCAL_FOLDER/$FILENAME.gz $LOCAL_FOLDER_HOURLY
testResult

#On garde les N recents dans hourly
/home/root/scripts/keepRecent/keepRecent.sh $LOCAL_FOLDER_HOURLY $NB_KEEP backup .sql.gz
testResult
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Finished keep recent on remote server"

#On teste si le serveur distant est un serveur de base ou non. La présence du fichier NODB indique que non.
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Starting install on other DB server"
if ssh transfert@$SERVER ls $REMOTE_FOLDER/NODB > /dev/null 2>&1 ; then
	echo "Distant server $SERVER is not a Database server. Database will not be installed there"
	if [[ ! "$FALLBACK_SERVER" == "" ]]; then
		echo "DB will be installed on fallback server : $FALLBACK_SERVER"
		ssh transfert@$FALLBACK_SERVER /home/root/scripts/transfert/installDBFromBackupServer.sh --dbname $DB_NAME --backupserver $SERVER --backupfilepath $REMOTE_FOLDER/$FILENAME.gz
		testResult
	fi 
else
	#On droppe et recrée la base en remote
	ssh transfert@$SERVER /home/root/scripts/transfert/createPostgresDatabase.sh $DB_NAME -virgin
	testResult
	
	#On installe la base en remote
	ssh transfert@$SERVER /home/root/scripts/transfert/installPostgresDb.sh $DB_NAME $REMOTE_FOLDER/$FILENAME.gz
	testResult
fi
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Finished install on other DB server"

if [[ ! "$RSYNC_DEST" == "" ]]; then
	ionice -c3 rsync -vaz --delete $LOCAL_FOLDER $RSYNC_DEST
	testResult
fi

#Envoi d'un status OK a Zabbix
endScript replicationPostgresDB
endScript $BACKUP_NAME
echo 'OK' > ~/.BACKUP_STATUS
echo "$DURATION" > ~/.BACKUP_STATUS_DURATION


