#!/bin/bash

### global para
export data_sets="400G"
#export data_sets="100m 1G 10G 20G 400G"


for data_set in $data_sets
do
	###
	bin=`dirname "$0"`
	bin=`cd "$bin"; pwd`
	cd $bin;
	from=$(date +%s)
	
	
	####
	host_name=`hostname`
	time_stamp=$(date +%s)
	in_dir="/tmp/terasort-input-"$data_set
	out_dir="/tmp/terasort-"$host_name"-"$data_set"-"$time_stamp
	hadoop_path=/root/jychen/softwares/hadoop-2.7.2/bin
	example_jar=/root/jychen/softwares/hadoop-2.7.2/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.2.jar
	
	#hadoop_path=/usr/bin
	#example_jar=~/hadoop-mapreduce-examples.jar
	
	
	#### go
	
	$hadoop_path/hadoop jar $example_jar terasort -D mapred.reduce.tasks=10 $in_dir $out_dir 
	
	### 
	now=$(date +%s)
	
	total_time=$(expr $now - $from )
	
	
	
	log="
	################################ \n
	terasort : [ $host_name ]  $data_set  => $total_time  (s)  \n
	 input =  $in_dir \n
	 output = $out_dir \n
	 start = $from \n
	 end = $now  \n
	 total run = $total_time \n
	################################
	"
	
	
	echo -e $log | tee -a "/tmp/terasort-"$host_name".log"

done
