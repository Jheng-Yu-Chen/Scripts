#!/bin/bash


BACKUPDIR="/backup/"

function BackupGPFSConfig() {
	#Ref: https://www.ibm.com/developerworks/community/wikis/home?lang=en#!/wiki/General%20Parallel%20File%20System%20(GPFS)/page/Back%20Up%20GPFS%20Configuration
	# Be safe:
	cd $BACKUPDIR
	
	# Get a list of the file systems
	# and backup the configuration for each one
	time=`date +"%Y-%m-%d"`
	for i in `mmlsconfig | grep "^/dev" | sed 's/\/dev\///' `
	do
	   echo Backing up configuration for $i
	   mmbackupconfig $i -o fsbackup_${time}_${i}.txt
	done
	
	# If CCR is enabled, and we're running v4.2 or greater, backup CCR database:
	mmccr backup -A ${BACKUPDIR}/ccr-backup-${time}
	
}

function Backup(){
	dsmc inc $BACKUPDIR -subdir=y 
}


BackupGPFSConfig

Backup
