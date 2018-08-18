#!/usr/bin/env python
# This script starts tomcat and after a brief delay opens browser and calls app url.
import sys
import subprocess
import time
import webbrowser
import os

tomcatStartupDelay = 10	
commandToStartTomcatProcess = "python TomcatManager.py start"
swingApp = "sudo python RunSwing.py"
browser = "sudo sh /home/pi/kweb1.sh &"
tProcess = subprocess.Popen(commandToStartTomcatProcess, stdout=subprocess.PIPE, shell=True)
out, err = tProcess.communicate()
print "Waiting for application initialization"
time.sleep(tomcatStartupDelay )
print "Opening application page"
#tProcess = subprocess.Popen(browser, stdout=subprocess.PIPE, shell=True)
#out, err = tProcess.communicate()
#webbrowser.open_new("http://localhost:8080/PiClient/pages/showImg.jsp")
#os.system(browser)
