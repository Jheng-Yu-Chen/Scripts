#!/bin/bash

cd /for_backup

DATE=`date -d 'now - 1 month'  +%Y%m`

rm -rf /for_backup/redmine_${DATE}*

