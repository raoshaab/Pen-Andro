#!/bin/bash 
#Author: @github.com/raoshaab
#############Checking for pre-condition###########
#Want to learn adb in easy way 
# https://adbshell.com/



function banner(){
          #Color change  everytime
           echo -e "\e[3$(( $RANDOM * 6 / 32767 + 1 ))m"
           
            bann0='
            mmmmm                         mm              #          mmmm
            #   "#  mmm   m mm            ##   m mm    mmm#   m mm  m"  "m
            #mmm#" #"  #  #"  #          #  #  #"  #  #" "#   #"  " #  m #
            #      #""""  #   #   """    #mm#  #   #  #   #   #     #    #
            #      "#mm"  #   #         #    # #   #  "#m##   #      #mm#
            
            
            #Author: github.com/@raoshaab'
            bann1='
             _____                                   _        _ 
            |  __ \                  /\             | |     / _ \ 
            | |__) |___ _ __ ______ /  \   _ __   __| |_ __| | | |
            |  ___// _ \  _ \______/ /\ \ |  _ \ / _  |  __| | | |
            | |   |  __/ | | |    / ____ \| | | | (_| | |  | |_| |
            |_|    \___|_| |_|   /_/    \_\_| |_|\__,_|_|   \___/ 
            '


            while IFS= read -r -n 1 -d '' c; do   printf '\e[38;5;%dm%s\e[0m'  "$((RANDOM%255+1))" "$c"; done <<<$bann0
}
banner
pwd_tools="${HOME}/.local/share/android_pentest_ready"
mkdir $pwd_tools >/dev/null 2>&1

#Downloading script to pwd_tools directory      
curl -sL https://raw.githubusercontent.com/raoshaab/Pen-Andro/dev/pen-andro.sh -o ${HOME}/.local/share/android_pentest_ready/pen-andro.sh
chmod +x $pwd_tools/pen-andro.sh
#Creating a soft link of script to /usr/bin/
sudo ln -sf ${pwd_tools}/pen-andro.sh /usr/bin/pen-andro >/dev/null 2>&1
#adding excute permission

echo -e "\t\t\n\nPen-Andro is installed on device "
echo -e "\t\t\nNow run with pen-andro "

