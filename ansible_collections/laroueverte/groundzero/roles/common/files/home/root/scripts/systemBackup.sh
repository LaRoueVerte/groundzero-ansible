#!/bin/bash
function executeCmd() {
	echo "$1"
	if [[ ! $2"" == "dryrun" ]]; then
		eval "$1"
	fi
}

cd

. /home/root/scripts/base.sh
showHeader

while [[ $1 != "" ]]; do
	if [[ $1 == "--sourcepath" ]] ; then
	   SOURCE_PATH=$2
	   shift
	   shift
	fi
	if [[ $1 == "--destinationpath" ]] ; then
	   DESTINATION_PATH=$2
	   shift
	   shift
	fi
	if [[ $1 == "--backupfilename" ]] ; then
	   BACKUP_FILENAME=$2
	   shift
	   shift
	fi
	if [[ $1 == "--server" ]] ; then
	   SERVER=$2
	   shift
	   shift
	fi
	if [[ $1 == "--exclusionpaths" ]] ; then
	   EXCLUSION_OPTIONS=""
	   for exclusionpath in $2 ; do
	     EXCLUSION_OPTIONS+="--exclude '.$exclusionpath' " 
	   done
	   shift
	   shift
	fi
	if [[ $1 == "--becometransfert" ]] ; then
	   SSH_IDENTITY_OPTION="-i /home/transfert/.ssh/id_rsa"
	   shift
	fi
	if [[ $1 == "--dryrun" ]] ; then
	   DRY_RUN="dryrun"
	   shift
	fi
done

if [ $SOURCE_PATH"" == "" ] || [ $DESTINATION_PATH"" == "" ] || [ $SERVER"" == "" ] || [ $BACKUP_FILENAME"" == "" ]; then
        echo "Usage $0 --sourcepath sourcepath --destinationpath destinationpath --backupfilename backupfilename --server server [--exclusionpaths] [--becometransfert] [--dryrun]"
        echo "Example: $0 --sourcepath / --destinationpath /home/transfert/remotedir/ --backupfilename remotedir-slash --server myserver.mycompany.net --exclusionpaths "/boot /dev" --becometransfert --dryrun"
        exit 1
fi

BACKUPSRC_MOUNTPOINT=/mnt/backupsrc
CURRENT_DATE=`date +%Y-%m-%d`
BACKUP_FILE_FULLPATH=$DESTINATION_PATH/$BACKUP_FILENAME-$CURRENT_DATE.tar.gz

# Create mount path for backup
executeCmd "mkdir -p $BACKUPSRC_MOUNTPOINT" $DRY_RUN

# Bind Mount the source path to backup
executeCmd "mount --bind $SOURCE_PATH $BACKUPSRC_MOUNTPOINT" $DRY_RUN

# tar and send to destination server
if [[ ! $DRY_RUN"" == "dryrun" ]]; then
	SOURCE_FOLDER_SIZE=`du -sh $BACKUPSRC_MOUNTPOINT | cut -f 1`
	echo "Estimated size of uncompressed source folder is : $SOURCE_FOLDER_SIZE"
fi
executeCmd "tar $EXCLUSION_OPTIONS -zcf - -C $BACKUPSRC_MOUNTPOINT -c . | pv | ssh $SSH_IDENTITY_OPTION transfert@$SERVER 'cat > $BACKUP_FILE_FULLPATH'" $DRY_RUN

# Unmount source path
executeCmd "umount $BACKUPSRC_MOUNTPOINT" $DRY_RUN

# Clean up destination backups
echo "Please clean behind you, do not forget to delete old backups on $SERVER in $DESTINATION_PATH !"
if [[ ! $DRY_RUN"" == "dryrun" ]]; then
	read -p 'Did you really clean up (yes/no)? ' CLEANED_OLD_BACKUPS
	while [[ ! $CLEANED_OLD_BACKUPS"" == "yes" ]]
	do
		read -p 'Did you really clean up (yes/no)? ' CLEANED_OLD_BACKUPS
	done
fi	
