#!/bin/bash

Files="/var/www/html/redmine/ /etc/httpd/conf/httpd.conf /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/redmine.conf /etc/pki/tls/certs/localhost.crt /etc/pki/tls/private/localhost.key"
Dst="/for_backup"

tar -jcPf ${Dst}/redmine_`date +%Y%m%d`.tar.bz2 $Files
