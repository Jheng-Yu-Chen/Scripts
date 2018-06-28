#!/bin/bash
START_TIME=`date +%s`
DURATION=`echo "24 * 60 * 60" | bc`
END_TIME=`echo "$START_TIME + $DURATION" | bc`


echo "Start Time: `date -d @$START_TIME`" | tee -a test.log


i=0
while true
do
	NOW=`date +%s`
	if [ "$NOW" -le "$END_TIME" ]; then
		i=`expr $i + 1`
		./iozone -i 0 -o -r 4k -f iozone.${i} -s 10g > /dev/null 2>> error.log
	else 
		echo $i
		echo "End Time: `date`" | tee -a test.log
		cat error.log
		break
	fi
done




