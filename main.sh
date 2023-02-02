#!/bin/bash 
#Author: @github.com/raoshaab
#############Checking for pre-condition###########
#Want to learn adb in easy way 
# https://adbshell.com/

pwd_tools="${HOME}/.local/share/android_pentest_ready"
mkdir $pwd_tools >/dev/null 2>&1

#Downloading script to pwd_tools directory      
curl -sL https://raw.githubusercontent.com/raoshaab/Pen-Andro/main/pen-andro.sh -o ${HOME}/.local/share/android_pentest_ready/pen-andro.sh

#Creating a soft link of script to /usr/bin/

sudo ln -sf ${pwd_tools}/pen-andro.sh /usr/bin/pen-andro >/dev/null 2>&1






