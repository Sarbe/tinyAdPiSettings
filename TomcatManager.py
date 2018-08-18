#!/usr/bin/env python
# This is an init script to start, stop, check status & restart tomcat.
import sys
import subprocess
import time

scriptName = 'tomact_init.py'
tomcatBinDir = '/home/pi/apache-tomcat-8.0.35/bin'
tomcatShutdownPeriod = 5
commandToCheckTomcatProcess = "ps -ef | grep -v grep | grep " + tomcatBinDir + " | wc -l"
commandToFindTomcatProcessId = 'ps -ef | grep -v grep | grep ' + tomcatBinDir + ' | awk \'{print $2}\''

def isProcessRunning():
    pStatus = True
    tProcess = subprocess.Popen(commandToCheckTomcatProcess, stdout=subprocess.PIPE, shell=True)
    out, err = tProcess.communicate()
    if int(out) < 1:
        pStatus = False
    return pStatus

def usage():
    print "Usage: python " + scriptName + " start|stop|status|restart"
    print "or"
    print "Usage: <path>/" + scriptName + " start|stop|status|restart"

def start():
    if isProcessRunning():
        print "Tomcat process is already running"
    else:
        print "Starting the tomcat"
        subprocess.Popen([tomcatBinDir + "/startup.sh"], stdout=subprocess.PIPE)

def stop():
    if isProcessRunning():
        print "Stopping the tomcat"
        subprocess.Popen([tomcatBinDir + "/shutdown.sh"], stdout=subprocess.PIPE)
        time.sleep(tomcatShutdownPeriod)
        if isProcessRunning():
            tPid = subprocess.Popen([commandToFindTomcatProcessId], stdout=subprocess.PIPE, shell=True)
            out, err = tPid.communicate()
            subprocess.Popen(["kill -9 " + out], stdout=subprocess.PIPE, shell=True)
            print "Tomcat failed to shutdown, so killed with PID " + out
    else:
       print "Tomcat process is not running"

def status():
    if isProcessRunning():
        tPid = subprocess.Popen([commandToFindTomcatProcessId], stdout=subprocess.PIPE, shell=True)
        out, err = tPid.communicate()
        print "Tomcat process is running with PID " + out
    else:
       print "Tomcat process is not running"

if len(sys.argv) != 2:
    print "Missing argument"
    usage()
    sys.exit(0)
else:
    action = sys.argv[1]

if action == 'start':
    start()
elif action == 'stop':
    stop()
elif action == 'status':
    status()
elif action == 'restart':
    stop()
    start()
else:
    print "Invalid argument"
    usage()
