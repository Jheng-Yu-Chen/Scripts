#!/bin/bash
#####################################################################
# recover closed index
#####################################################################


function Check_Status() {
        STATUS=$1
        if [ "$STATUS" -ne 0 ]; then
                echo -e '  [ \033[31m failed \033[0m ]'
                exit 1
        else
                echo -e '  [ \033[32m ok \033[0m ]'
        fi
}


echo 'Getting index informations ... '
INDICES=`curl  -sS -XGET "192.168.10.180:9200/_cat/indices" | grep close | cut -d ' ' -f 8`


for INDEX in $INDICES
do
	echo "Opening index ... "
	curl  -sS -XPOST "192.168.10.180:9200/$INDEX/_open" &> /dev/null

	while :
	do
		echo 'Wating 300 sec for index recovery complete ... '
		STATUS=`curl  -sS 192.168.10.180:9200/_cluster/health?pretty | grep green`
		if [ ! "$STATUS" ]; then
			sleep 60
		else
			echo 'Recovery completed!'
			break
		fi
	done

	echo -n "Waiting relocation $INDEX ... "
	sleep 3600
	
	echo -n "Closing index: $INDEX ... "
        curl  -sS -XPOST "192.168.10.180:9200/$INDEX/_close" &> /dev/null
	Check_Status $?
done
