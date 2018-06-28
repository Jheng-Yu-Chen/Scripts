#!/bin/bash
bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
cd $bin;
from=$(date +%s)


/root/jychen/softwares/hadoop-2.7.2/bin/hadoop jar /root/jychen/softwares/hadoop-2.7.2/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.2.jar teragen 2200000 /tmp/terasort-input-100m

/root/jychen/softwares/hadoop-2.7.2/bin/hadoop jar /root/jychen/softwares/hadoop-2.7.2/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.2.jar teragen 22000000 /tmp/terasort-input-1G


/root/jychen/softwares/hadoop-2.7.2/bin/hadoop jar /root/jychen/softwares/hadoop-2.7.2/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.2.jar teragen 220000000 /tmp/terasort-input-10G

/root/jychen/softwares/hadoop-2.7.2/bin/hadoop jar /root/jychen/softwares/hadoop-2.7.2/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.2.jar teragen 440000000 /tmp/terasort-input-20G

/root/jychen/softwares/hadoop-2.7.2/bin/hadoop jar /root/jychen/softwares/hadoop-2.7.2/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.2.jar teragen 8800000000 /tmp/terasort-input-400G

now=$(date +%s)

total_time=$(expr $now - $from )

