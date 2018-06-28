#1/bin/bash
USERNAME='USERNAME'
PASSWD='USERNAME'
DATABASE='obj_usage'

source /root/jychen/openrc_iphoto

DATA=$(swift stat)

CONTAINERS=$(awk '{print $4}' <<< $DATA)
OBJECTS=$(awk '{print $6}' <<< $DATA)
BYTES=$(awk '{print $8}' <<< $DATA)


TIMESTAMP=`date +%s%N`


curl -XPOST "http://XXXXXXXXXX:8086/write?db=${DATABASE}" -u ${USERNAME}:${PASSWD} --data-binary "$OS_USERNAME,item=containers value=$CONTAINERS
$OS_USERNAME,item=objects value=$OBJECTS
$OS_USERNAME,item=bytes value=$BYTES $TIMESTAMP"

