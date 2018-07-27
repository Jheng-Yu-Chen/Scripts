#!/bin/bash
#
# tested in "GNU bash, version 4.3.48(1)-release (x86_64-pc-linux-gnu)"
# Last Modified: 2018/07/27


# Getting GPU info and storing result into hostGPU array
IFS=$'\n' read -d '' -r -a hostGPU < <(nvidia-smi -L)

# Generatting JSON data
echo "{"
echo "\"data\":["

for ((i=0;i<${#hostGPU[@]};i++))
do
	# last json line end without ","
	if [ $i -eq `echo $((${#hostGPU[@]}-1))` ]; then
		# substr($X, 1, length($X)-1) -> removing last char like : or ) 
		echo ${hostGPU[$i]} | awk '{print "{ \"{#GPUID}\":" "\"" substr($2, 1, length($2)-1) "\"," "\"{#GPUUUID}\":" "\"" substr($6, 1, length($6)-1) "\"" " }"}'
	else
		echo ${hostGPU[$i]} | awk '{print "{ \"{#GPUID}\":" "\"" substr($2, 1, length($2)-1) "\"," "\"{#GPUUUID}\":" "\"" substr($6, 1, length($6)-1) "\"" " },"}'
	fi
done
echo "]"
echo "}"

