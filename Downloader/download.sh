#!/bin/bash

############################## Start of File - download.sh #####################
## Create on 06-Aug-2016 - V1
## Modified on 12-Jun-2017
## Download the updates available for the machine
##
#################################################################################

set -x

dt=$(date +%Y-%m-%d)
logDt=$(date +%Y-%m-%d-%H-%M-%S)


piclient=/home/pi/piclient
dwnldFolder=$piclient/download
scriptFolder=$piclient/scripts
log=$piclient/logs/downloader_$dt.log
dwnldFileName=$dwnldFolder/patch.tar.gz

#SERIAL
DEVICE_SERIAL_NBR=$(cat /proc/cpuinfo | grep Serial | cut -d ' ' -f 2| awk '{print toupper($0)}')
##

printf "==================================================================" >> "$log"
printf "\n<<<<<<<<<< Staring download.sh @@ %s >>>>>>>>" "$logDt " >> "$log"


serverURL=http://www.tinyad.in/PiVisionWeb/client/Payload
chkForDwnld=$serverURL/softwareDownloadStatus/$DEVICE_SERIAL_NBR
dwnldURL=$serverURL/downloadSoftware/$DEVICE_SERIAL_NBR
stsURL=$serverURL/updateDownloadStatus/$DEVICE_SERIAL_NBR

printf "\n chkForDwnld :: %s" "$chkForDwnld" >> "$log"
printf "\n dwnldURL :: %s" "$dwnldURL" >> "$log"
printf "\n stsURL :: %s" "$stsURL" >> "$log"

count=$(pgrep wget|grep -v -c grep)

if [ "$count" -eq 0 ]   #downloader not running
then
	#check if download is available
	rcvd_hash=$(wget -qO- "$chkForDwnld")
	
	if [ "$rcvd_hash" != "NA" ]
	then
		#Clean up download folder
		printf "\nCleaning Download folder." >> "$log"
		cd "$dwnldFolder" && sudo rm -rf ./*
		cd "$scriptFolder" || exit
		#download software
		printf "\nStarting downloding Patch ...." >> "$log"
		## download the file
		# -nc  - if present donot download again
		# -O specify folder
		wget -nc -O "$dwnldFileName" "$dwnldURL"
		rc=$?
		
		if [ "$rc" -eq 0 ] 
		then
			printf "\nFile downloaded Successfully." >> "$log"
			# Check for hash
			file_hash=$(sha1sum "$dwnldFileName"| awk '{print $1}')
			printf "\nChecking for Authenticity ......" >> "$log"
			if [ "$file_hash" = "$rcvd_hash" ]
			then
				printf "\nFile is Authenticate." >> "$log"
				printf "\nUpdating server for file is downloaded successfully !!!" >> "$log"
				# Update web that download is finished
				wget -qO- "$stsURL/D"
								
				#install
				# 1. unzip
				printf "\nInstalling patch process started ...." >> "$log"
				cd "$dwnldFolder"||exit
				printf "\nGoing to download folder" >> "$log"
				#unzip
				tar -zxvf "$dwnldFileName"
				sts=$?
				if [ "$sts" -eq 0 ] #tar file is opened successfully
				then
					printf "\nUnzipped the file..." >> "$log"
					#2. run the run script
					sudo sh run.sh "$log"
					sts=$?
					if [ "$sts" -eq 0 ] #run.sh ran successfully
					then
						printf "\nInstallation is successful." >> "$log"

						#3. Update status to web as installed
						wget -qO- "$stsURL/E"
						printf "\nStatus update to web as Executed(E) " >> "$log"

						printf "\nUpgrade finished @@ %s" "$logDt " >> "$log"
												
					else
						printf "\nProblem running run.sh. Mailing Admin" >> "$log"
						mail -s "Pi: $DEVICE_SERIAL_NBR - Error during running download.sh" "sarbe97@gmail.com" < "$log"
					fi
											
				else
					printf "\nUnzip failed" >> "$log"
					#remove all file
					rm -rf dwnldFolder
				fi
			else
				printf "\nChecksum validation failed" >> "$log"
				#remove all files
				rm -rf dwnldFolder
			fi
		fi
	else
		printf "\nNo download available" >> "$log"
	fi
	
else
    printf "\nProcess Already running. Existing....."+ >> "$log"
    exit
fi

printf "\n<<<<<<<<<<<<<<<<End of process @@ %s >>>>>>>>>>>>>>> \n" "$logDt " >> "$log"

#################################### End of File ###################################
