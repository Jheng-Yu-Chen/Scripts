#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/usr/lpp/mmfs/bin

mmces service list | grep "NFS is running"

if [ "$?" == "0" ]; then
	echo 0
	logger "`hostname` NFS is OK!"
else 
	logger "`hostname` NFS is DOWN!"
	mmces service start nfs
fi




