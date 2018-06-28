#!/bin/bash


BackupTarget="/gpfs/"

function CleanupS3FSTmp() {
	rm -rf /gpfs/s3fs_tmp/*
}

function CheckGPFSStatus() {
	DiskStatus=$(mmlsdisk object | grep -w up | wc -l)
	if [ $DiskStatus != "5" ]; then
		echo 'GPFS one or more disk is down!'
		exit 1
	fi
}

function Backup(){
	dsmc inc $BackupTarget -subdir=y 
}





CheckGPFSStatus

CleanupS3FSTmp

Backup
