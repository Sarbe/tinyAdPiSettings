#!/bin/bash
piclient=/home/pi/piclient
logFolder=$piclient/logs
log=$1

#SERIAL
DEVICE_SERIAL_NBR=$(cat /proc/cpuinfo | grep Serial | cut -d ' ' -f 2| awk '{print toupper($0)}')

logFIles=$(find "$logFolder" -name 'client_audit.log.*') 

uploadURL="http://www.tinyad.in/PiVisionWeb/client/Payload/uploadFile?displayKey=$DEVICE_SERIAL_NBR"

echo ">>>>>>>>>>>>>>>>>>>>>>Upload Started >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" >> "$log"
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
		echo "File :$file uploaded successfully," >> "$log"
		rm "$file.gz"
	else
		echo "Error while uploadig file :$file" >> "$log"
		exit 1
	fi
done

echo ">>>>>>>>>>>>>>>>>>>>>>Upload finished >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" >> "$log"
exit 0
