#!/bin/bash


ELASTIC_PW='PASSWORD'
KIBANA_PW='PASSWORD'
LOGSTASH_PW='PASSWORD'
CLUSTER_IP=`ip a | grep inet | grep ens224 | cut -d ' ' -f 6 | cut -d '/' -f 1`


function INITIAL_SETTINGS() {
echo -n 'Creating YUM RPEO file ... '
cat << EOF > /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-6.x]
name=Elasticsearch repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
echo 'OK'

echo -n 'rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch ... '
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch &> /dev/null && echo 'OK' || echo 'Failed'


}

function ELASTICSEARCH() {

echo -n 'yum install elasticsearch -y ... '
yum install elasticsearch -y &> /dev/null && echo 'OK' || echo 'Failed'

echo 'Configuring /etc/sysconfig/elasticsearch :'
echo -n 'ES_JAVA_OPTS="-Xms31g -Xmx31g" ... '
sed -i '18s/.*/ES_JAVA_OPTS="-Xms31g -Xmx31g"/' /etc/sysconfig/elasticsearch &> /dev/null && echo 'OK' || echo 'Failed'

echo -n 'MAX_OPEN_FILES=65536 ... '
sed -i '39s/.*/MAX_OPEN_FILES=65536/' /etc/sysconfig/elasticsearch &> /dev/null && echo 'OK' || echo 'Failed'

echo -n 'MAX_LOCKED_MEMORY=unlimited ... '
sed -i '46s/.*/MAX_LOCKED_MEMORY=unlimited/' /etc/sysconfig/elasticsearch &> /dev/null && echo 'OK' || echo 'Failed'

echo -n 'MAX_MAP_COUNT=262144 ... '
sed -i '51s/.*/MAX_MAP_COUNT=262144/' /etc/sysconfig/elasticsearch &> /dev/null && echo 'OK' || echo 'Failed'


echo -n 'echo 'vm.max_map_count = 262144' >> /etc/sysctl.conf ... '
echo 'vm.max_map_count = 262144' >> /etc/sysctl.conf  && echo 'OK' || echo 'Failed'

echo -n 'sysctl -p ... '
sysctl -p &> /dev/null && echo 'OK' || echo 'Failed'

echo 'Configuring /etc/elasticsearch/elasticsearch.yml'
echo -n 'Creating config file ... '
cat ./cluster1-elasticsearch.yml > /etc/elasticsearch/elasticsearch.yml && echo 'OK' || echo 'Failed'

echo -n 'transport.host: $CLUSTER_IP ... '
sed -i "s/transport.host: CHANGE_ME/transport.host: $CLUSTER_IP/g" /etc/elasticsearch/elasticsearch.yml &> /dev/null && echo 'OK' || echo 'Failed'

echo -n 'systemctl daemon-reload ... '
systemctl daemon-reload &> /dev/null && echo 'OK' || echo 'Failed'

echo 'Installing X-Pack : '
cd /usr/share/elasticsearch/
echo 'Y' | bin/elasticsearch-plugin install x-pack

echo -n 'mkdir -p /elasticsearch_data/NFS'
mkdir -p /elasticsearch_data/NFS &> /dev/null && echo 'OK' || echo 'Failed'

echo -n 'chown -R elasticsearch. /elasticsearch_data/ ... '
chown -R elasticsearch. /elasticsearch_data/ &> /dev/null && echo 'OK' || echo 'Failed'

echo 'Starting elasticsearch ... '
systemctl restart elasticsearch.service &> /dev/null && sleep 30 ; echo 'OK' || echo 'Failed'

echo 'Enabling elasticsearch ... '
systemctl enable elasticsearch.service &> /dev/null && sleep 30 ; echo 'OK' || echo 'Failed'
}

function SETUP_SECURITY() {


echo 'Setup password : '
cd /usr/share/elasticsearch/
echo 'Y' | bin/x-pack/setup-passwords auto


echo -n "Creating a new user ... "
cd /usr/share/elasticsearch/
echo 'Y' | bin/x-pack/users useradd USERPWD -p USERPWDUSERPWD -r superuser &> /dev/null && sleep 10 ; echo 'OK' || echo 'Failed'


echo -n "Changing elastic passwords ... "
curl -sS -XPOST 'http://USERPWD:USERPWDUSERPWD@localhost:9200/_xpack/security/user/elastic/_password' -H "Content-Type: application/json" -d'{  "password": "orWiWo4cabAFYZUaQfdm"}' &> /dev/null && echo 'OK' || echo 'Failed'

echo -n "Changing kibana passwords ... "
curl -sS -XPOST 'http://USERPWD:USERPWDUSERPWD@localhost:9200/_xpack/security/user/kibana/_password' -H "Content-Type: application/json" -d'{  "password": "JGhFfAXEGG-C!eyBdIkI"}' &> /dev/null && echo 'OK' || echo 'Failed'

echo -n "Changing logstash passwords ... "
curl -sS -XPOST 'http://USERPWD:USERPWDUSERPWD@localhost:9200/_xpack/security/user/logstash_system/_password' -H "Content-Type: application/json" -d'{  "password": "3P1*ZrR=a!L9iIUEv=Gw" }' &> /dev/null && echo 'OK' || echo 'Failed'

}


function KIBANA() {

echo -n 'yum install kibana -y ... '
yum install kibana -y &> /dev/null && echo 'OK' || echo 'Failed'

echo 'Configuring kibana ... '
cat > /etc/kibana/kibana.yml <<EOF
server.port: 5601
server.host: "0.0.0.0"
server.name: "$(hostname)"
elasticsearch.url: "http://$CLUSTER_IP:9200"
kibana.index: ".kibana"
elasticsearch.username: "kibana"
elasticsearch.password: "${KIBANA_PW}"
EOF
echo 'OK'


echo 'Installing Kibana X-Pack ... '
cd /usr/share/kibana/
echo 'Y' | bin/kibana-plugin install x-pack

echo -n 'Starting Kibana ... '
systemctl restart kibana &> /dev/null && echo 'OK' || echo 'Failed'

echo -n 'Enabling Kibana ... '
systemctl enable kibana &> /dev/null && echo 'OK' || echo 'Failed'
}

function LOGSTASH() {
echo -n 'yum install logstash -y ... '
yum install logstash -y &> /dev/null && echo 'OK' || echo 'Failed'

echo 'Installing Logstash X-Pack ... '
cd /usr/share/logstash/
bin/logstash-plugin install x-pack

cat >> /etc/logstash/logstash.yml << EOF
xpack.monitoring.enabled: true
xpack.monitoring.elasticsearch.url: [ "http://172.16.10.78:9200/", "http://172.16.10.79:9200/"]
xpack.monitoring.elasticsearch.username: "logstash_system"
xpack.monitoring.elasticsearch.password: "${LOGSTASH_PW}"
xpack.monitoring.elasticsearch.sniffing: true
EOF

echo -n 'sed -i 's/User=logstash/User=root/g' /etc/systemd/system/logstash.service ... '
sed -i 's/User=logstash/User=root/g' /etc/systemd/system/logstash.service &> /dev/null && echo 'OK' || echo 'Failed'

echo -n 'sed -i 's/Group=logstash/User=root/g' /etc/systemd/system/logstash.service ... '
sed -i 's/Group=logstash/User=root/g' /etc/systemd/system/logstash.service &> /dev/null && echo 'OK' || echo 'Failed'

echo -n 'systemctl daemon-reload ... '
systemctl daemon-reload &> /dev/null && echo 'OK' || echo 'Failed'

echo -n 'scp -oStrictHostKeyChecking=no 172.16.10.80:/etc/logstash/conf.d/docker.conf /etc/logstash/conf.d/docker.conf'
scp -oStrictHostKeyChecking=no 172.16.10.80:/etc/logstash/conf.d/docker.conf /etc/logstash/conf.d/docker.conf &> /dev/null && echo 'OK' || echo 'Failed'

echo -n 'Starting Logstash ... '
systemctl restart logstash &> /dev/null && echo 'OK' || echo 'Failed'

echo -n 'Enabling Logstash ... '
systemctl enable logstash &> /dev/null && echo 'OK' || echo 'Failed'
}


echo '#############################################'
echo '#Initializing Settings'
echo '#############################################'
INITIAL_SETTINGS

echo '#############################################'
echo '#Installing Elasticsearch '
echo '#############################################'
ELASTICSEARCH


echo '#############################################'
echo '#SETUP SECURITY '
echo '#############################################'
SETUP_SECURITY

echo '#############################################'
echo '#Installing Kibana '
echo '#############################################'
KIBANA


echo '#############################################'
echo '#Installing Logstash '
echo '#############################################'
LOGSTASH
