#!/bin/bash
if [[ "$1" == "" ]] ; then
        echo "Usage $0 trapperForZabbix [rsync] [rsyncdir] "
        echo "        rsync : optional boolean [true|false]. If true, rsyncs the logs to the rsyncdir directory"
        exit
fi;

cd

. /home/root/scripts/base.sh
NB_KEEP=370
FILENAME_START_ACCESS=access
FILENAME_START_ERROR=error
FILENAME_EXT=.log
DEST_FOLDER=/var/log/apache2/vlogs
SCRIPT_TRAPPER=$1
RSYNC_ENABLED=$2
RSYNC_DEST=$3

if [ "$2" == "pretend" ]; then
        PREFIX=echo
else
        PREFIX= 
fi

#Keep start date of the script
startScript $SCRIPT_TRAPPER

#On supprime les fichiers plus vieux que 1 an et 10 jours
for a in `seq 10 500`; do
        DATE=`date --date "last year - $a days" +%Y-%m-%d`
        $PREFIX rm $DEST_FOLDER/*/access-$DATE.log
        $PREFIX rm $DEST_FOLDER/error-$DATE.log
done

#On supprime les liens symboliques cassés
for a in  $DEST_FOLDER/*/access.log ; do if [[ ! -e $a ]]; then rm $a; fi; done

#On supprime les dossiers vides
find  $DEST_FOLDER -maxdepth 1 -depth -type d -empty -exec $PREFIX rmdir {} \;

if [[ "$RSYNC_ENABLED" == "true" ]]; then
	echo "Launching rsync from $DEST_FOLDER to $RSYNC_DEST"
	/home/root/scripts/rsyncbackup/rsyncbackup.sh NONE $DEST_FOLDER $RSYNC_DEST
fi

#Envoi d'un status OK a Zabbix
endScript $SCRIPT_TRAPPER