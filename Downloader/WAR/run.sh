#!/bin/bash
############################## Start of File - run.sh #####################
## Create on 09-Jun-2017 - V1
## mention the steps
#################################################################################


piclient=/home/pi/piclient
dwnldFolder=$piclient/download
tomcatDir=/home/pi/apache-tomcat-8.0.35
webappsDir=$tomcatDir/webapps
binDir=$tomcatDir/bin
log=$2   #/home/pi/piclient/logs/log.log

## Mention the steps to be run on machine - Start

#shutdown tomcat
echo "Shutting down tomcat ......"
sudo sh "$binDir"/shutdown.sh
sts=$?
if [ "$sts" -eq 0 ]
then
    echo "\nTomcat stopped....">> "$log"
    # remove piclient
    # cd $webappsDir
    rm -rf "$webappsDir"/PiClient.war "$webappsDir"/PiClient
    sts=$?
    if [ "$sts" -eq 0 ]
    then
        echo "Project removed from webapps dir" >> "$log"
        echo "Copying Projects to webapps dir" >> "$log"
        cp "$dwnldFolder"/PiClient.war "$webappsDir"
        echo "Starting Tomcat .... " >> "$log"
        #Start Tomcat
        sudo sh "$binDir"/startup.sh
        sts=$?
        if [ "$sts" -eq 0 ]
        then
            echo "Tomcat Started........." >> "$log"
        else
            echo "Error While starting Tomcat.........." >> "$log"
			exit 1
        fi
        echo "Application deployed Successfully.">> "$log"
		#Restart Machine
		#printf "\nRestarting Machine......\n" >> "$log"
		#sudo shutdown -r now
    else
        echo "Error while removing the project." >> "$log"
		exit 1
    fi
else
    echo "Error while shutting down Tomcat" >> "$log"
	exit 1
fi

### End