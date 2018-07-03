#!/bin/bash
#############################################
# Purpose: backup afasi pictures.
# 
# Last Modified Date: 2018/07/02
# LIMITATIONS: 
#	1. Spaces are not allowed in directory and file name.
#############################################



# Configuration
## 
backupDirectory="/etc"
backupDestination="/backup"
sqlFile="backupAndEncrypt.sql"
tableName="TABLE_NAME"

# Script config
MD5SUM="/usr/bin/md5sum"
STAT="/usr/bin/stat"
dateYYMMDD=`date +%Y%m%d`
tempDir="/tmp/$dateYYMMDD"

# START: Functions

#文字的顏色，用法font_color -sf --color [red|green] --text [要顯示的文字]
#-s : [OK]
#-f : [FAILED]
function font_color(){
	if [ $# == 1 ]; then
		if [ $1 == "-s" ]; then
			echo -e "[" "\033[32m"OK"\033[0m" "]"
		fi
		if [ $1 == "-f" ]; then
	                echo -e "[" "\033[31m"FAILED"\033[0m" "]"
		fi
	fi

	while [ $# -gt 0 ]
	do
	        case $1 in
	        --color)
	                color=$2
	                shift
	                ;;
	        --text)
	                text=$2
	                shift
	                ;;
	        esac
	        shift
	done

	case $color in
	        red)
	                echo -e "\033[31m${text}\033[0m"
	                ;;
	        green)
	                echo -e "\033[32m${text}\033[0m"
			;;
	esac
}

check_status(){
	export status=$?
	while [ $# -gt 0 ]
        do
                case $1 in
                "-t")
                        text=$2
                        shift
                        ;;
                esac
                shift
        done

	if [ "$status" -eq 0 ]; then
       	        font_color -s
       	        return 0
       	else
       	        font_color -f
		echo "$text"
       	        return 1
       	fi

}

# END: Functions


### Main ###

# initializing env

echo '### Start: initializing env ###'

echo -n "mkdir -p $tempDir ... "
mkdir -p $tempDir 
check_status

echo -n "Checking is $backupDestination exist and writable ... "
test -d $backupDestination &> /dev/null && touch ${backupDestination}/test
check_status
if  [ "$status" -gt 0 ]; then
	echo "$backupDestination doesn't exist or writable!"
	exit
else 
	rm -f ${backupDestination}/test
fi

echo -n "Checking is $MD5SUM exist and executable ... "
test -f $MD5SUM &> /dev/null && $MD5SUM --version &>/dev/null
check_status
if  [ "$status" -gt 0 ]; then
	echo "$MD5SUM doesn't exist and executable!"
	exit
fi

echo -n "Checking is $STAT exist and executable ... "
test -f $STAT &> /dev/null && $STAT --version &>/dev/null
check_status
if  [ "$status" -gt 0 ]; then
	echo "$STAT doesn't exist and executable!"
	exit
fi

echo '### End: initializing env ###'
echo '#########################################'

echo '### Start: Do the backup ###'
# Scanning backup location and generatting file's md5
# Output format will be: ModifiedTime sizeInBytes MD5 filePathAndFilename
echo -n "find $backupDirectory -type f -exec sh -c \"stat -c '%Y %s' {} | tr '\n' ' '\" \; -exec md5sum {} \; > ${tempDir}/fileChecksum.list ... "
find $backupDirectory -type f -exec sh -c "stat -c '%Y %s' {} | tr '\n' ' '" \; -exec md5sum {} \; > ${tempDir}/fileChecksum.list 2> ${tempDir}/runtime.log
check_status

if  [ "$status" -gt 0 ]; then
	read -p 'There are some error occurred! Do you want to continue? (y/n) ' yn
	case $yn in
		[Yy]* ) echo 'continue ... ';;
		[Nn]* ) exit 1;;
	esac
fi

# Convertting to relative path
echo -n "sed -i "s/ ${backupDirectory}\// /g" ${tempDir}/fileChecksum.list ... "
sed -i "s| ${backupDirectory}/| |g" ${tempDir}/fileChecksum.list
check_status

# Encryption and rename
while read line
do
	dateInSec=`date +%s`
	# get modification time in seconds
	modTime=`echo $line | awk '{print $1}'`
	# get file size in bytes
	fileSize=`echo $line | awk '{print $2}'`
	# get md5
	md5=`echo $line | awk '{print $3}'`

	if [[ ! "$line" =~ "/" ]]; then

		# Get filename
		filename=`echo $line | awk '{print $NF}'`
		# get relative path
		path=""
	else
		# Get filename
		filename=`echo $line | awk -F"/" '{print $NF}'`
		# get relative path
		path=`echo $line | awk '{print $NF;}' | sed "s|/$filename||g"`
		
	fi

	# encrypting and backup files
	echo -n "Do $filename encryption and backup ... "
	if [ "$path" == "" ]; then
		tar -cvf "${backupDestination}/${dateInSec}-${modTime}-${fileSize}-${md5}_${filename}.tar" "${backupDirectory}/${filename}" > /dev/null 2>> ${tempDir}/runtime.log
		check_status
	else
		mkdir -p "${backupDestination}/${path}"
		tar -cvf "${backupDestination}/${path}/${dateInSec}-${modTime}-${fileSize}-${md5}_${filename}.tar" "${backupDirectory}/${path}/${filename}" > /dev/null 2>> ${tempDir}/runtime.log
		check_status
	fi

	# Generatting SQL Syntax
	echo "INSERT INTO \`$tableName\` VALUES (\"$dateYYMMDD\", \"$dateInSec\", \"$modTime\", \"$fileSize\", \"$md5\", \"$path\", \"$filename\");" >> $sqlFile

done < "${tempDir}/fileChecksum.list"

echo '### End:  Do the backup ###'


# cleanup
echo '### Start: cleanup env ###'

echo -n "mkdir -p $tempDir ... "
rm -rf $tempDir &> /dev/null
check_status

echo '### End: cleanup env ###'
