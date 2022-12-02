#!/bin/bash 
#Author: @github.com/raoshaab
#############Checking for pre-condition###########




#for Burpsuite
function burp(){
      check=$(curl -s http://127.0.0.1:8080/ 2>/dev/null  |grep Burp -o|head -n1)

      if [[ $check == Burp ]]
      then 
            echo "+------------------------------------------+"
            echo "|                                          |"
            echo "|         Burpsuite Running done !!        |"
            echo -e "+------------------------------------------+\n\n"
            

      
      else
            echo -e "\033[1;91m" 
            echo "+-------------------------------------------- +"
            echo "|                  Error                      |" 
            echo "| Burpsuite proxy not running (127.0.0.1:8080)|" 
            echo -e "+---------------------------------------------+\n\n" && banner && exit
      fi


}

#For Internet connectivity 
function net(){
      
       ping 8.8.8.8 -c1 &>/dev/null 
      if [ $? == 0 ]; then
             echo -e "\033[0;92m"
          #  echo "+------------------------------------------+"
          #  echo "|                                          |"
          #  echo "|         Internet Ready to go             |" 
          #  echo -e "+------------------------------------------+\n\n"
      else 
      echo -e "\033[1;91m" 
            echo "+------------------------------------------+"
            echo "|               Error                      |"
            echo "|             No Internet                  |" 
            echo -e "+------------------------------------------+\n\n"&& banner && exit
      fi
}

####### For adb  & Root Acess 
function adb_check(){
      adb get-state >/dev/null 2>&1 
      if [ $? == 0 ];then
            echo "+------------------------------------------+"
            echo "|                                          |"
            echo "|                adb Connected !!          |"
            echo -e "+------------------------------------------+\n\n"
      else  
            echo -e "\033[1;91m" 
            echo "+------------------------------------------+"
            echo "|       adb is not running                 |"
            echo "|               oR                         |"
            echo "|   More than one emulator exits           |" 
            echo -e "+------------------------------------------+\n\n"&& banner && exit
      fi
      #checking root access
      adb shell -n 'su -c ""' >/dev/null 2>&1
      if [ $? == 0 ]; then
            echo ' '
           
      else 
            echo "+------------------------------------------+"
            echo "|                                          |"
            echo "|  Give root Access to adb from Superuser  |"
            echo -e "+------------------------------------------+\n\n"&& banner && exit
      fi

        

}


#====================================================================Before Starting ===================================================================
#https://github.com/whalehub/custom-certificate-authorities
#https://pswalia2u.medium.com/install-burpsuites-or-any-ca-certificate-to-system-store-in-android-10-and-11-38e508a5541a
###############  Moving Certificate for android via adb -----------------------------------
function burpcer(){ 

     cert_check=$(adb shell 'su -c "ls /system/etc/security/cacerts|grep 9a5ba575.0"')
     res='y'
     #checking existing Burpsuite certificate
      if [[ "$cert_check" == "9a5ba575.0" ]]
      then 
            echo -e "\033[1;91m" 
            echo -e "Already Burpsuite Certificate found, this will replace existing one\n"
            
            echo -e "\033[0;92mIf you want to replace it press Y if not then N/n " 
            exec < /dev/tty && read res && exec <&-
      
      fi
      
      if [[ $res == 'N' || $res == 'n' ]]
      then  
            echo 'No changes in Burp Certificate '
      elif [[ $res == 'Y' || $res == 'y' ]] ;then 
            wget --quiet  127.0.0.1:8080/cert -O cacert.der 
            openssl x509 -inform DER -in cacert.der -out cacert.pem
            name=$(echo $(openssl x509 -inform PEM -subject_hash_old -in cacert.pem | head -1).0)
            mv cacert.pem $name
            adb push $name /sdcard/ >/dev/null 2>&1
            adb remount >/dev/null 2>&1  
            adb shell -n "su -c 'remount'" >/dev/null 2>&1 
            if [ $? == 0 ];then 
                  echo ' ' 
            else 
                  adb shell -n "su -c 'mount -o r,w /'"  >/dev/null 2>&1 
            fi
            adb shell -n "su -c 'mv /sdcard/$name /system/etc/security/cacerts'" >/dev/null 2>&1 
            adb shell -n "su -c 'chmod 644  /system/etc/security/cacerts/$name'" >/dev/null 2>&1 
            
              
            echo "+------------------------------------------+"
            echo "|                                          |"
            echo "|      Certificate Move Successfully       |"
            echo -e "+------------------------------------------+\n\n"
            echo "Device will reboot now :><: " 
            adb reboot &
            

      fi
}

#All Apps 
############### Proxy toggle----------------------- 
function andro_apps(){
      prox_app=$(adb shell "pm list packages -3|cut -f 2 -d ":"|grep com.kinandcarta.create.proxytoggle"|tr -d '\r')
      if [[ "$prox_app" = "com.kinandcarta.create.proxytoggle" ]]
      then
            echo 'ProxyToggle Already installed'
      else
            wget --quiet https://github.com/theappbusiness/android-proxy-toggle/releases/download/v1.0.1/Proxy.Toggle.v1.0.1.zip
            unzip -q Proxy.Toggle.v1.0.1.zip 
            adb install -t -r proxy-toggle.apk >/dev/null 2>&1
            adb shell pm grant com.kinandcarta.create.proxytoggle android.permission.WRITE_SECURE_SETTINGS 
            echo "+------------------------------------------+"
            echo "|                                          |"
            echo "|            Proxy App installed           |"
            echo -e "+------------------------------------------+\n\n"
      fi

      ############### ADB WIFI -------------------------

      prox_app=$(adb shell "pm list packages -3|cut -f 2 -d ":"|grep com.sujanpoudel.adbwifi"|tr -d '\r')
      if [[ "$prox_app" == "com.sujanpoudel.adbwifi" ]]
      then
            echo 'ADB Wifi Already installed'
      else
            wget -q https://github.com/raoshaab/Andro_set/raw/main/assets/adb_wifi.apk -O wifiadb.apk
            adb install -t -r wifiadb.apk
            echo "+------------------------------------------+"
            echo "|                                          |"
            echo "|         ADB Wifi App installed           |"
            echo -e "+------------------------------------------+\n\n"
      fi
      ##############Proxy Droid -----------------------

      prox_app=$(adb shell "pm list packages -3|cut -f 2 -d ":"|grep  org.proxydroid"|tr -d '\r')
      if [[ "$prox_app" == "org.proxydroid" ]]
      then
            echo 'ProxyDroid Already installed'
      else

            wget -q https://github.com/raoshaab/Andro_set/raw/main/assets/org.proxydroid.apk -O proxydroid.apk
            adb install  -t -r proxydroid.apk
            echo "+------------------------------------------+"
            echo "|                                          |"
            echo "|         ProxyDroid App installed         |"
            echo -e "+------------------------------------------+\n\n"
      fi


}

#Pc tools 


function pc_tools(){
      ################ JADX - Dex to Java decompiler, apktool
      ################ Android Screen Share 
      (jadx --version | scrcpy  -v && apktool -version) &>/dev/null  
      if [[ $? != 0 ]]
      then
            echo 'Installing Pc Tools ' 
            apt-get -qq install jadx  scrcpy apktool -y &>/dev/null 
           
            echo "+------------------------------------------+"
            echo "|                                          |"
            echo "|     JADX~Apktool~Scrcpy  installed       |"
            echo -e "+------------------------------------------+\n\n"
      
      else
            echo "+------------------------------------------+"
            echo "|                                          |"
            echo "|  JADX~Apktool~Scrcpy already installed   |"
            echo -e "+------------------------------------------+\n\n"
      fi

      (frida --version  && objection version )>&/dev/null
      if [ $? == 0 ];then 
            echo "+------------------------------------------+"
            echo "|                                          |"
            echo "|   Frida Objection already installed      |"
            echo -e "+------------------------------------------+\n\n"

      else
            pip3 install frida frida-tools objection  &>/dev/null 
            
            echo "+------------------------------------------+"
            echo "|                                          |"
            echo "|         Frida Setup Ready                |"
            echo -e "+------------------------------------------+\n\n"
      fi
}

#android 

# not able match android_cpu with frida, use ~= ,using regex to match 

#if magisk is available then frida_magisk module will install 
function magisk_module(){
    #frida
      magisk_version=$(curl -IkLs -o /dev/null -w %{url_effective}  https://github.com/ViRb3/magisk-frida/releases/latest|grep -o "[^/]*$"| sed "s/v//g")
      baseurl="https://github.com/ViRb3/magisk-frida/releases/download/$magisk_version/MagiskFrida-$magisk_version.zip"
      wget --quiet $baseurl -O frida_module.zip
      adb push frida_module.zip /data/local/tmp 
      adb shell -n "su -c  'magisk  --install-module /data/local/tmp/frida_module.zip'"

      #trust 
      wget -q https://github.com/NVISOsecurity/MagiskTrustUserCerts/releases/download/v0.4.1/AlwaysTrustUserCerts.zip -O trust_module.zip
      adb push   trust_module.zip /data/local/tmp  >/dev/null 2>&1
      adb shell -n "su -c  'magisk  --install-module /data/local/tmp/trust_module.zip'" >/dev/null 2>&1

      echo "Frida Module installed on Device"


}


function frida_ando(){
      #Checking for frida-server in android 
            frida_android=$(adb shell "frida-server --version") 2>/dev/null 
      if [[ $? == 0 ]]
      then 
            echo -e "\033[1;91m Frida-server already Installed with  $frida_android \n\n \033[0;92mIf you want to upgrade or reinstall Press Y/y "
            exec < /dev/tty && read res && exec <&- 
      fi

      if [[ $res == 'Y' || $res == 'y' ]]
      then 
            magisk_version=$(adb shell "magisk -v|cut -d ':' -f2")
            if [[ $magisk_version == "MAGISK" ]]
            then  
            #magisk  will flash frida server module which autostart on reboot
                  magisk_module

            else 
                  android_cpu=$(adb shell getprop | egrep "ro.product.cpu.abi]"|awk '{print $2}'|sed 's/\[//g'|sed 's/\]//g')
                  frida_version=$(curl -IkLs -o /dev/null -w %{url_effective}  https://github.com/frida/frida/releases/latest|grep -o "[^/]*$"| sed "s/v//g")

                  ##choose frida server matches android cpu---------------------------
                  baseurl="https://github.com/frida/frida/releases/download/$frida_version/frida-server-$frida_version-android-"

                  if   [[ $android_cpu =~ ^x86 ]]; then
                        server_download="x86"
                  elif [[ $android_cpu =~ ^arm64 ]]; then
                        server_download="arm64"
                  
                  elif [[ $android_cpu =~ ^x86_64 ]]; then
                        server_download="x86_64"
                  elif [[ $android_cpu =~ ^arm ]]; then
                        server_download="arm"
                  else 
                        echo something is wrong
                  fi

                  ## Download frida-server and copy to android /data/local/tmp/ 
                  echo 'Downloading Frida server'
                  wget  -q $baseurl$server_download.xz -O frida-server.xz
                  unxz frida-server.xz >/dev/null 2>&1
                  adb push frida-server /data/local/tmp/ >/dev/null 2>&1
                  adb shell -n "su -c 'chmod 777 /data/local/tmp/frida-server'" >/dev/null 2>&1 
                  adb remount >/dev/null 2>&1  
                  adb shell -n "su -c 'remount'" >/dev/null 2>&1 
                  if [ $? == 0 ];then 
                        echo ' ' 
                  else 
                        adb shell -n "su -c 'mount -o r,w /'"  >/dev/null 2>&1 
                  fi
                  adb shell -n "su -c 'mv /data/local/tmp/frida-server /system/xbin/'"
                  echo 'Frida Server copied  to Android system'
            
                  echo "+------------------------------------------+"
                  echo "|                                          |"
                  echo "|  Setup Ready  with Android frida         |"
                  echo -e "+------------------------------------------+\n\n"
                  echo ""
                  echo "adb shell -n su -c frida-server --version "
      fi 
      else 
            echo 'Frida-server Installed'  
      fi
}


## To install magisk in Genymotion 
#will add this in future 
function install_magisk(){
           # if device ==genymotion 
           # then 
                  adb push magisk.zip /sdcard/
                  adb shell "/system/bin/flash-archive.sh /sdcard/magisk.zip"


}


#frida version mismatch

function frida_mismatch(){
      ps_version=$(frida --version 2>/dev/null )
      android_frida_version=$(adb shell -n 'sh -c "frida-server --version"'  2>/dev/null)
      echo "Comming soon :) "

}





function all(){
      burp
      net 
      adb_check
      pc_tools
      andro_apps
      frida_ando

      }

################ All neccesary function defined above ###################

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
function start(){
      #cooking script directory, 
            banner      
            base_dir='/tmp/android_pentest_ready'
            cd /tmp/
            rm -rf android_pentest_ready  >/dev/null 2>&1
            mkdir android_pentest_ready >/dev/null 2>&1 && cd android_pentest_ready 

            
            echo -e "\033[0;37m"
            echo -e "\n1. All"
            echo "2. Move Burpsuite Certificate to Android root folder"
            echo "3. Pc Tools (JADX, frida, objection, Android Screen Control & Mirror "
            echo "4. Android Frida Server"
            echo "5. Fix Frida Server Version mismatch"
            echo "6. Android Apps(proxytoogle, proxydroid, ADBwifi)"
            echo "0. Exit "
            echo -e "\e[3$(( $RANDOM * 6 / 32767 + 1 ))m"
            echo -e "I want to install  :-"
            # Allows us to read user input below, assigns stdin to keyboard and then again to script
            exec < /dev/tty && read option && exec <&- && clear
            

            #Acting on the user input
            case $option in
            1) all
            ;;
            2) net;adb_check;burp;burpcer
            ;;
            3) net; pc_tools;   
            ;;
            4) net; adb_check ;frida_ando
            ;;
            5) net; frida_mismatch;
            ;;
            6) net; adb_check; andro_apps
            ;;
            0) banner;exit
            ;;
            esac 
            start       

}

start
