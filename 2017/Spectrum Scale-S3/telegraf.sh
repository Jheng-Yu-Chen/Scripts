#!/bin/bash
mkdir -p /var/log/telegraf
telegraf -config /etc/telegraf/telegraf.conf &>> /var/log/telegraf/telegraf.log &

