#!/bin/bash


source /root/bin/.openrc_iphoto
for i in $(seq 1 7) 
do
	school_album=`cat school${i}.txt | grep 'photo.aspx' | cut -d '>' -f 4 | cut -d '<' -f 1`
	for album in $school_album
	do
		swift post ${album}
		swift post ${album}_180
		swift post ${album}_1200
	done
done

