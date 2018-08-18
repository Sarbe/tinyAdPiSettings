import RPi.GPIO as GPIO ## Import GPIO library
import time ## Import 'time' library. Allows us to use 'sleep'
import subprocess
import sys
import os



#pid = str(os.getpid())
#pidfile = "/home/pi/Switcher.pid"


#if os.path.isfile(pidfile):
#    print "%s already exists, exiting" % pidfile
#    sys.exit()
#file(pidfile, 'w').write(pid)

old_stdout = sys.stdout
log_file = open("message.log","w")
adDuration = 60
sleepDuration = 300

checkTVState = '/opt/vc/bin/tvservice -s'
touch = 'touch ' +'/home/pi/piclient'+ '/' +'startFlag.tmp'
remove = 'rm -f ' +'/home/pi/piclient'+ '/' +'startFlag.tmp'
reboot = 'sudo reboot'
checkBrowser = 'ps -efx | grep x-www-browser | wc -l'
browser = "epiphany-browser -a --profile ~/.config http://localhost:8080/PiClient/pages/showImg.jsp --display=:0 &"

separator = "="
propertyfile  = '/home/pi/apache-tomcat-8.0.35/webapps/PiClient/WEB-INF/classes/config.properties'

def readPropertyFile():
	with open(propertyfile) as f:

		for line in f:
			if separator in line:

				# Find the name and value by splitting the string
				name, value = line.split(separator, 1)

				# Assign key value pair to dict
				# strip() removes white space from the ends of strings
				#keys[name.strip()] = value.strip()
				if name == "adv.duration":
					print(name)
					adDuration = value
					print(value)
				if name == "tv.duration":
					print(name)
					sleepDuration = value
					print(value)

#print(keys)


##toggles switch on request
def toggleSwitch():
        GPIO.setmode(GPIO.BOARD) ## Use board pin numbering
        GPIO.setup(7, GPIO.OUT) ## Setup GPIO Pin 7 to OUT
        GPIO.output(7,True)## Switch on pin 7
        time.sleep(1)## Wait
        GPIO.output(7,False)## Switch off pin 7
        time.sleep(1)## Wait
        GPIO.cleanup()

def checkandfixHdmiState():
        print "fixing hdmi"
        tProcess = subprocess.Popen(checkTVState, stdout=subprocess.PIPE, shell=True)
        out, err = tProcess.communicate()
        var = 1
        while var == 1 : #keep on trying till pi is connected to hdmi
                if out.split(' ')[1] == '0x40001': # no hdmi cable connected during boot
                        print "not finding a display"
                        toggleSwitch() # try to bring hdmi switch to PI

                #need to obtain state again after swithcing
                tProcess = subprocess.Popen(checkTVState, stdout=subprocess.PIPE, shell=True)
                out, err = tProcess.communicate()

                if out.split(' ')[1] == '0x40002': # Not initialized but HDMI cable is connected (plugged in after boot)
                        print "found a display rebooting"
                        os.system(reboot)
                if (out.split(' ')[1] != '0x40002') or (out.split(' ')[1] != '0x40001'): #HDMI now in working state break out
                        print "hdmi fixed breaking to regular switching"
                        break

        #if already in connected state just reboot
        if out.split(' ')[1] == '0x40002': # Not initialized but HDMI cable is connected (plugged in after boot)
                print "found a display rebooting"
                os.system(reboot)

toggleSwitch() # toggle always before start
checkandfixHdmiState() # do this to ensure HDMI is available to Pi
readPropertyFile() # read and set swithching intervals for HDMI

try:
        toggleSwitch()
        var1 = 1
        while var1 == 1 :
                tProcess = subprocess.Popen(checkTVState, stdout=subprocess.PIPE, shell=True)
                out, err = tProcess.communicate()
                if (out.split(' ')[1] == '0x120006') or (out.split(' ')[1] == '0x12000a'): ## '0x12000a':
                        print "TV active showing ads"
                        os.system(touch)
						
						
						
                        time.sleep(adDuration) ## Ad window duration
                        os.system(remove)
                        tProcess = subprocess.Popen(checkTVState, stdout=subprocess.PIPE, shell=True)
                        out, err = tProcess.communicate()
                        if (out.split(' ')[1] == '0x120006') or (out.split(' ')[1] == '0x12000a'): ## '0x12000a': ## confirm ad still on before switching
                                toggleSwitch() ## change channel
                elif (out.split(' ')[1] == '0x40001') or  (out.split(' ')[1] == '0x40002'):
                        print "TV inactive trying to fix"
                        checkandfixHdmiState()
                else:
                        print "swithcing to TV and waiting"
                        time.sleep(sleepDuration) ## sleep for 5 minutes
                        toggleSwitch() ## change channel
finally:
        print " exiting "
        #os.unlink(pidfile)
