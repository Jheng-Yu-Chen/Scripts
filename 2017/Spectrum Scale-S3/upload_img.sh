#!/bin/bash


#for i in $(seq 1 7)
#do

	#cat school${i}.txt | grep "photo.aspx" | cut -d'"' -f 4 > school${i}_url.txt
	#sed -i -e 's/^/\\"/' school${i}_url.txt
	#sed -i -e 's/$/\\"/' school${i}_url.txt
	#sed -i -e 's/^/http:\/\/XXXXXXXXXX\/gh\/one_school\//' school${i}_encoded_url.txt


	#for value in `cat school${i}_url.txt`
	#do
	#	encoded_value=$(python -c "import urllib; print urllib.quote('''$value''')")
	#	echo $encoded_value >> school${i}_encoded_url.txt
	#done

	#value=`cat school${i}_url.txt | cut -d '=' -f 3`

	#echo $value $encoded_value
	#sed -i.bak "s/$value/$encoded_value/g" school${i}_url.txt

	#sed -i 's/./=/43' school${i}_encoded_url.txt


	#echo "--------- school${i}_encoded_url.txt ---------------"
	#cat school${i}_encoded_url.txt | wc -l
	#cat school${i}_url.txt | wc -l



#	for url in `cat school${i}_encoded_url.txt`
#	do
#		album_id=`echo $url | cut -d'=' -f 2 | cut -d'&' -f1`
#		#touch albums/$album_id
#		curl -sS $url | grep XXX.XXX..tw | cut -d '=' -f 3 | cut -d\' -f 2 >> albums/$album_id
#
#		
#	done
#done




source /root/bin/.openrc_iphoto
album=`cd /root/iphoto/albums/ ; ls *.txt`
for i in $album
do
	album_name=`echo $i | cut -d'.' -f 1`
#
	mkdir /root/iphoto/albums/${album_name}_orig
#	mkdir /root/iphoto/albums/${album_name}_180
#	mkdir /root/iphoto/albums/${album_name}_1200
#
	s3cmd mb s3://${album_name}
#	s3cmd mb s3://${album_name}_180
#	s3cmd mb s3://${album_name}_1200
#
#	cd /root/iphoto/albums/${album_name}
#	wget -q `cat /root/iphoto/albums/${i}`
	
	
	cd /root/iphoto/albums	
	orig_files=`ls ${album_name}/`

	for orig_file in $orig_files
	do
		#convert ${album_name}/${orig_file} -resize 180 ${album_name}_180/${orig_file}
		#convert ${album_name}/${orig_file} -resize 1200 ${album_name}_1200/${orig_file}

		#s3cmd put ${album_name}_180/${orig_file} s3://${album_name}_180/${orig_file}
		#s3cmd put ${album_name}_1200/${orig_file} s3://${album_name}_1200/${orig_file}
		#s3cmd put ${album_name}_1200/${orig_file} s3://${album_name}/${orig_file}
		convert ${album_name}/${orig_file} -quality 100 -filter Sinc -resize 1600 ${album_name}_orig/${orig_file}
		s3cmd put ${album_name}_orig/${orig_file} s3://${album_name}/${orig_file}

		
	done

#	for file in $files
#	do
#		swift upload ${i} $file
#		swift upload ${i}_180 $file
#		swift upload ${i}_1200 $file
#	done
#
#	cd /root/iphoto 
#	\rm -rf albums/${i}_tmp

done
