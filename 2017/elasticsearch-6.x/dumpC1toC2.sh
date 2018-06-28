#!/bin/bash



INDICES=$(curl -sS -XGET "http://USERPWD:USERPWDUSERPWD@172.16.10.79:9200/_cat/indices" | cut -d ' ' -f 3 | grep "jhengyu")


chmod 777 /elasticsearch_data

for INDEX in $INDICES
do
	echo "--------------------------------Data ${INDEX}----------------------------"
	elasticdump \
	--headers='{"Content-Type": "application/json"}' \
	--input=http://USERPWD:USERPWDUSERPWD@172.16.10.79:9200/$INDEX \
	--output=/elasticsearch_data/${INDEX}-data.json \
	--type=data --limit=10000

done

