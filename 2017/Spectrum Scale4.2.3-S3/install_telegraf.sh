#!/bin/bash
yum install OpenIPMI ipmitool make git -y

cd /usr/local/src 

wget https://storage.googleapis.com/golang/go1.6.2.linux-amd64.tar.gz

tar -zxvf go1.6.2.linux-amd64.tar.gz 

mv go go_1.6.2

go get github.com/influxdata/telegraf

cat <<EOF  >> /root/.bashrc
export GOROOT=/usr/local/src/go_1.6.2
export GOPATH=/usr/local/src/
export GOBIN=\$GOROOT/bin
export PATH=\$PATH:\$GOBIN
EOF

source /root/.bashrc

export GOROOT=/usr/local/src/go_1.6.2
export GOPATH=/usr/local/src/
export GOBIN=$GOROOT/bin
export PATH=$PATH:$GOBIN


cd $GOPATH/src/github.com/influxdata/telegraf

scp hcsdsc110:/usr/local/src/src/github.com/influxdata/telegraf/plugins/inputs/ipmi_sensor/connection.go /usr/local/src/src/github.com/influxdata/telegraf/plugins/inputs/ipmi_sensor/connection.go

make

mkdir -p /etc/telegraf/telegraf.d/

scp hcsdsc110:/etc/telegraf/telegraf.conf /etc/telegraf/telegraf.conf

scp hcsdsc110:~/telegraf.sh /root/telegraf.sh
