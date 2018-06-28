#!/bin/bash


BackupLocation="/backup/iphoto"

s3fsParameter='-o sigv2 -o use_path_request_style -o no_check_certificate -o passwd_file=/root/.s3fs -o use_cache=/gpfs/s3fs_tmp -o url=https://XXXXXXXXXXXXXXXXXX'


source /root/bin/.openrc_iphoto

#Check swift status
swift stat | grep 'AUTH_39d210775a3148ddac047525bc8c277f' &> /dev/null || exit 1

#Get bucket list
BucketList="$(swift list)"

#Check bucket quantity
if [ -z "$BucketList" ]; then
	echo 'No bucket to process!'
	exit 0
fi



function CleanupDir(){
	Directories=$(ls $BackupLocation)

	for Dir in $Directories
	do	
		swift list | grep -w $Dir &> /dev/null 

		if [ $? = 1 ]; then
			echo -n "Unmounting ${BackupLocation}/${Dir} ... "
			umount ${BackupLocation}/${Dir} &>/dev/null && echo OK || echo Failed

			echo -n "Deleting ${BackupLocation}/${Dir} ... "
			rm -rf ${BackupLocation}/${Dir} &>/dev/null && echo OK || echo Failed
		fi
	done
}


function BackupTarget(){
	Directories=$(ls $BackupLocation)

	for Dir in $Directories
	do	
		echo "${BackupLocation}/${Dir}/"
	done
}

function MountBucket(){
	BackupTarget=""
	for Bucket in $BucketList
	do
		if [ -d "${BackupLocation}/${Bucket}" ]; then
			echo -n "Check ${Bucket} mounted  ... "
			mount | grep -w ${Bucket} &>/dev/null
			
			if [ $? = 1 ]; then
				echo "Unmounted"
				echo -n "Mounting ${BackupLocation}/${Bucket} ... "
				s3fs ${Bucket} ${BackupLocation}/${Bucket} $s3fsParameter &>/dev/null && echo OK || echo Failed
			else
				echo "Mounted"
			fi
			
		else
			echo -n "Creating ${BackupLocation}/${Bucket} ... "
			mkdir -p ${BackupLocation}/${Bucket} &>/dev/null && echo OK || echo Failed

			echo -n "Mounting ${BackupLocation}/${Bucket} ... "
			s3fs ${Bucket} ${BackupLocation}/${Bucket} $s3fsParameter &>/dev/null && echo OK || echo Failed
		fi
	done

}


function UnmountAllBucket(){
	for Bucket in $BucketList
        do
		echo -n "Unmouting $Bucket ... "
		umount -f ${BackupLocation}/${Bucket} && echo OK || echo Failed
	done

}

function Backup(){
	echo $BucketList > "/backup/iphotoBucketList/buckets_$(date +%Y-%m-%d).txt"
	for target in ${BucketList}
	do
		dsmc inc ${BackupLocation}/${target} -subdir=y 
	done
}




CleanupDir

MountBucket

Backup

UnmountAllBucket
