#!/bin/bash
############################## Start of File - download.sh #####################
## Upload audit log files
## Create on 01-Apr-2017 - V1
##
#################################################################################
set -x

dt=$(date +%Y-%m-%d)
logDt=$(date +%Y-%m-%d-%H-%M-%S)

piclient=$HOME/piclient
logFolder=$piclient/logs

#SERIAL
DEVICE_SERIAL_NBR=$(cat /proc/cpuinfo | grep Serial | cut -d ' ' -f 2| awk '{print toupper($0)}')

logFIles=$(find "$logFolder" -name 'client_audit.log.*') 

uploadURL="http://www.tinyad.in/PiVisionWeb/client/Payload/uploadFile?displayKey=$DEVICE_SERIAL_NBR"

log=$piclient/logs/uploader_$dt.log
echo ">>>>>>>>>>>>>>>>>>>>>>Upload Started @$logDt>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" >> "$log"
for file in $logFIles
do
	echo "$file"
	#Zipping File
	echo "Zipping file before transmission" >> "$log"
	gzip "$file"
	curl -F "upload=@$file.gz;filename=$file.gz" "$uploadURL"
	rc=$?
	
	if [ "$rc" -eq 0 ] 
	then
		echo "File :$file uploaded successfully @$logDt" >> "$log"
		rm "$file.gz"
	else
		echo "Error while uploadig file :$file" >> "$log"
	fi
done

echo ">>>>>>>>>>>>>>>>>>>>>>Upload finished @$logDt>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" >> "$log"

