#!/bin/bash
#
# Purpose: find all duplicated files
#

DIRECTORY="/usr"

find $DIRECTORY -type f -exec md5sum {} \; > /tmp/checksum.list

# find all duplicated files
DUPLICATE=`cat /tmp/checksum.list | awk '{print $1}' | sort | uniq -c | awk '{if ($1 > 1) print $2 }'`

# print duplicated files
for HASH in $DUPLICATE
do
	grep "$HASH" /tmp/checksum.list
	echo ""
done

#cleanup
rm -f /tmp/checksum.list
