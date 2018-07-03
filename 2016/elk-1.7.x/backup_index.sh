#!/bin/bash
#####################################################################
# Using elasticdump to backup elasticsearch index to outside storage
#####################################################################


DATE_TIME="$1"
BACKUP_DIR='/dump_data/'

if [ ! $DATE_TIME ]; then
	echo 'Please provide year and month or index name which you want to backup!'
	echo 'Example: backup_index.sh 2016.11 OR backup_index.sh jhengyu_15001-2016.11'
	exit 1
fi

function Check_Status() {
        STATUS=$1
        if [ "$STATUS" -ne 0 ]; then
                echo -e '  [ \033[31m failed \033[0m ]'
                exit 1
        else
                echo -e '  [ \033[32m ok \033[0m ]'
        fi
}

function Zip_File() {
	FILE_LIST=`ls $BACKUP_DIR | grep $DATE_TIME | grep -v .gz`
	for FILE in $FILE_LIST
	do
		echo -n "gzip ${BACKUP_DIR}/$FILE ... "
		gzip ${BACKUP_DIR}/$FILE 
		Check_Status $?
	done
}

function Delete_Index() {
	for INDEX in $INDICES
	do
		echo -n "Deleting index $INDEX ... "
		curl -sS -XDELETE "192.168.10.180:9200/$INDEX/" &> /dev/null
		Check_Status $?
	done
}



echo 'Getting index informations ... '
INDICES=`curl  -sS -XGET "192.168.10.180:9200/_cat/indices" | grep close | grep $DATE_TIME | cut -d ' ' -f 8`


if [ ! "$INDICES" ]; then
	echo 'Failed'
	echo "No index name contains $DATE_TIME!"
fi


for INDEX in $INDICES
do
	echo "Opening index ... "
	curl  -sS -XPOST "192.168.10.180:9200/$INDEX/_open" &> /dev/null


	
	while :
	do
		echo 'Wating 10 sec for index recovery complete ... '
		STATUS=`curl  -sS 192.168.10.180:9200/_cluster/health?pretty | grep green`
		if [ ! "$STATUS" ]; then
			sleep 10
		else
			echo 'Recovery completed!'
			break
		fi
	done
	
	echo 'Starting backup ... '
	elasticdump --input=http://192.168.10.180:9200/${INDEX} --type=data --limit=10000 --output=/dump_data/${INDEX}-data.json	
	Check_Status $?


	echo -n "Closing index: $INDEX ... "
        curl  -sS -XPOST "192.168.10.180:9200/$INDEX/_close" &> /dev/null
	Check_Status $?
	
done

Zip_File

Delete_Index
