#!/bin/sh
export DISPLAY=:0.0
kweb -KHCUAJ+-zbhrqfpoklgtjneduwxyavcsmi#?!., http://localhost:8080/PiClient/pages/showImg.jsp & > /dev/null
while true; do
sleep 5m
WID=$(xdotool search --onlyvisible --class kweb)
xdotool windowactivate $WID key alt+r
done

