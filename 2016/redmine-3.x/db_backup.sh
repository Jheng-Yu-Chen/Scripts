#!/bin/bash

User="USERNAME"
Passwd="PASSWORD"
Dst="/for_backup"
Database="db_redmine"

/bin/mysqldump --user="$User" --password="$Passwd" $Database > $Dst/redmine_`date +%Y%m%d`.sql

