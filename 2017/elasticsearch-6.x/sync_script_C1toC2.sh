#!/bin/bash



SYSTEM_INDICES=$(curl -sS -XGET "http://USERPWD:USERPWDUSERPWD@127.0.0.1:9200/_cat/indices" | cut -d ' ' -f 3 | grep -v -e ".monitoring" -e ".watcher-history" -e "jhengyu" )

OTHER_INDICES=$(curl -sS -XGET "http://USERPWD:USERPWDUSERPWD@127.0.0.1:9200/_cat/indices" | cut -d ' ' -f 3 | grep -v -e ".monitoring" -e ".watcher-history" -e ".watches" -e ".kibana" -e ".triggered_watches" -e ".security-6" -e "jhengyu" )


echo -n 'scp -oStrictHostKeyChecking=no /etc/elasticsearch/x-pack/role_mapping.yml 172.16.10.80:/etc/elasticsearch/x-pack/role_mapping.yml ...'
scp -oStrictHostKeyChecking=no /etc/elasticsearch/x-pack/role_mapping.yml 172.16.10.80:/etc/elasticsearch/x-pack/role_mapping.yml &> /dev/null && echo 'ok' || echo 'failed'

echo -n 'scp -oStrictHostKeyChecking=no /etc/elasticsearch/x-pack/role_mapping.yml 172.16.10.81:/etc/elasticsearch/x-pack/role_mapping.yml ...'
scp -oStrictHostKeyChecking=no /etc/elasticsearch/x-pack/role_mapping.yml 172.16.10.81:/etc/elasticsearch/x-pack/role_mapping.yml &> /dev/null && echo 'ok' || echo 'failed'


echo -n 'scp -oStrictHostKeyChecking=no /etc/sysconfig/iptables 172.16.10.80:/etc/sysconfig/iptables ... '
scp -oStrictHostKeyChecking=no /etc/sysconfig/iptables 172.16.10.80:/etc/sysconfig/iptables &> /dev/null && echo 'ok' || echo 'failed'


echo -n 'scp -oStrictHostKeyChecking=no /etc/sysconfig/iptables 172.16.10.81:/etc/sysconfig/iptables ... '
scp -oStrictHostKeyChecking=no /etc/sysconfig/iptables 172.16.10.81:/etc/sysconfig/iptables &> /dev/null && echo 'ok' || echo 'failed'

echo -n 'ssh 172.16.10.80 systemctl reload iptables ... '
ssh 172.16.10.80 systemctl reload iptables &> /dev/null && echo 'ok' || echo 'failed'

echo -n 'ssh 172.16.10.81 systemctl reload iptables ... '
ssh 172.16.10.81 systemctl reload iptables &> /dev/null && echo 'ok' || echo 'failed'

export DAYS="7"
export DATES=""
for (( i=0; i<=${DAYS}; i=i+1 ))
do
        export DATES="$DATES `date -d \"-${i} days\" '+%Y.%m.%d'`"

done

for INDEX in $SYSTEM_INDICES
do
	echo "--------------------------------Metadata ${INDEX}----------------------------"
	elasticdump \
	--headers='{"Content-Type": "application/json"}' \
	--input=http://USERPWD:USERPWDUSERPWD@172.16.10.79:9200/$INDEX \
	--output=http://USERPWD:USERPWDUSERPWD@172.16.10.81:9200/$INDEX \
	--type=mapping --limit=1000
	
	echo "--------------------------------Data ${INDEX}----------------------------"
	elasticdump \
	--headers='{"Content-Type": "application/json"}' \
	--input=http://USERPWD:USERPWDUSERPWD@172.16.10.79:9200/$INDEX \
	--output=http://USERPWD:USERPWDUSERPWD@172.16.10.81:9200/$INDEX \
	--type=data --limit=10000
done



for DATE in $DATES
do
	INDEX="jhengyu-accesslog-$DATE"
	echo "--------------------------------Metadata ${INDEX}----------------------------"
	elasticdump \
	--headers='{"Content-Type": "application/json"}' \
	--input=http://USERPWD:USERPWDUSERPWD@172.16.10.79:9200/$INDEX \
	--output=http://USERPWD:USERPWDUSERPWD@172.16.10.81:9200/$INDEX \
	--type=mapping --limit=1000
	
	echo "--------------------------------Data ${INDEX}----------------------------"
	elasticdump \
	--headers='{"Content-Type": "application/json"}' \
	--input=http://USERPWD:USERPWDUSERPWD@172.16.10.79:9200/$INDEX \
	--output=http://USERPWD:USERPWDUSERPWD@172.16.10.81:9200/$INDEX \
	--type=data --limit=10000

	

done

for DATE in $DATES
do
        INDEX="jhengyu-docker-$DATE"
        echo "--------------------------------Metadata ${INDEX}----------------------------"
        elasticdump \
        --headers='{"Content-Type": "application/json"}' \
        --input=http://USERPWD:USERPWDUSERPWD@172.16.10.79:9200/$INDEX \
        --output=http://USERPWD:USERPWDUSERPWD@172.16.10.81:9200/$INDEX \
        --type=mapping --limit=1000

        echo "--------------------------------Data ${INDEX}----------------------------"
        elasticdump \
        --headers='{"Content-Type": "application/json"}' \
        --input=http://USERPWD:USERPWDUSERPWD@172.16.10.79:9200/$INDEX \
        --output=http://USERPWD:USERPWDUSERPWD@172.16.10.81:9200/$INDEX \
        --type=data --limit=10000



done

for DATE in $DATES
do
        INDEX="jhengyu-container-log-$DATE"
        echo "--------------------------------Metadata ${INDEX}----------------------------"
        elasticdump \
        --headers='{"Content-Type": "application/json"}' \
        --input=http://USERPWD:USERPWDUSERPWD@172.16.10.79:9200/$INDEX \
        --output=http://USERPWD:USERPWDUSERPWD@172.16.10.81:9200/$INDEX \
        --type=mapping --limit=1000

        echo "--------------------------------Data ${INDEX}----------------------------"
        elasticdump \
        --headers='{"Content-Type": "application/json"}' \
        --input=http://USERPWD:USERPWDUSERPWD@172.16.10.79:9200/$INDEX \
        --output=http://USERPWD:USERPWDUSERPWD@172.16.10.81:9200/$INDEX \
        --type=data --limit=10000



done

	#jhengyu-container-log-$DATE
	#jhengyu-docker-$DATE



for INDEX in $OTHER_INDICES
do
	echo "--------------------------------Metadata ${INDEX}----------------------------"
	elasticdump \
	--headers='{"Content-Type": "application/json"}' \
	--input=http://USERPWD:USERPWDUSERPWD@172.16.10.79:9200/$INDEX \
	--output=http://USERPWD:USERPWDUSERPWD@172.16.10.81:9200/$INDEX \
	--type=mapping --limit=1000
	
	echo "--------------------------------Data ${INDEX}----------------------------"
	elasticdump \
	--headers='{"Content-Type": "application/json"}' \
	--input=http://USERPWD:USERPWDUSERPWD@172.16.10.79:9200/$INDEX \
	--output=http://USERPWD:USERPWDUSERPWD@172.16.10.81:9200/$INDEX \
	--type=data --limit=10000
done


