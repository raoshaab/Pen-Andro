
#Author: @raodev
#############Checking for pre-condition###########




#for Burpsuite
function burp(){
      check=$(curl -s http://127.0.0.1:8080/ 2>/dev/null |grep Burp -o|head -n1)

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
      
      wget -q https://google.com/ --spider >>/dev/null
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
      adb get-state 2>/dev/null
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
      adb shell -n 'su -c ""' 2>/dev/null
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
            echo "Already Burpsuite Certificate is there this will replace existing one "
            echo "If you want to replace it press Y/y else N/n" && read res
                    
      fi
      
      if  [[ $res == "N/n" ]]
            then 
            exit
      else
            wget --quiet  127.0.0.1:8080/cert -O cacert.der 
            openssl x509 -inform DER -in cacert.der -out cacert.pem
            name=$(echo $(openssl x509 -inform PEM -subject_hash_old -in cacert.pem | head -1).0)
            mv cacert.pem $name
            adb push $name /sdcard/
            adb remount 2>/dev/null  
            adb shell -n "su -c 'remount'" 2>/dev/null 
            if [ $? == 0 ];then 
                  echo ' ' 
            else 
                  adb shell -n "su -c 'mount -o r,w /'"  2>/dev/null 
            fi
            adb shell -n "su -c 'mv /sdcard/$name /system/etc/security/cacerts'" 2>/dev/null 
            adb shell -n "su -c 'chmod 644  /system/etc/security/cacerts/$name'" 2>/dev/null 
            
            #adb reboot  
            echo "+------------------------------------------+"
            echo "|                                          |"
            echo "|      Certificate Move Successfully       |"
            echo -e"+------------------------------------------+\n\n"
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
            adb install -t -r proxy-toggle.apk 2>/dev/null
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

start
}

#Pc tools 


function pc_tools(){
      ################ JADX - Dex to Java decompiler, apktool
      ################ Android Screen Share 
      apt-get -qq install jadx  scrcpy apktool -y 2>/dev/null
      echo "+------------------------------------------+"
      echo "|                                          |"
      echo "|          JADX & Scrcpy  installed        |"
      echo -e "+------------------------------------------+\n\n"
      
      frida --version 2>&1 >/dev/null && objection version 2>&1 >/dev/null
      if [ $? == 0 ];then 
            echo "+------------------------------------------+"
            echo "|                                          |"
            echo "|   Frida Objection already installed      |"
            echo -e "+------------------------------------------+\n\n"

      else
            pip3 install frida frida-tools objection  2>/dev/null
 
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
      adb push   trust_module.zip /data/local/tmp  2>/dev/null
      adb shell -n "su -c  'magisk  --install-module /data/local/tmp/trust_module.zip'" 2>/dev/null

      echo "Frida Module installed on Device"


}


function frida_ando(){
     ## if  adb shell 'frida-server --version' -n then 
      
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
            unxz frida-server.xz 2>/dev/null
            adb push frida-server /data/local/tmp/ 2>/dev/null
            adb shell -n "su -c 'chmod 777 /data/local/tmp/frida-server'" 2>/dev/null 
            adb remount 2>/dev/null  
            adb shell -n "su -c 'remount'" 2>/dev/null 
            if [ $? == 0 ];then 
                  echo ' ' 
            else 
                  adb shell -n "su -c 'mount -o r,w /'"  2>/dev/null 
            fi
            adb shell -n "su -c 'mv /data/local/tmp/frida-server /system/xbin/'"
            echo 'Frida Server copied  to Android system'
      
            echo "+------------------------------------------+"
            echo "|                                          |"
            echo "|  Setup Ready  with Android frida         |"
            echo -e "+------------------------------------------+\n\n"
            echo ""
            echo "adb shell -n su -c frida-server --version "
     #Command to set here to run the android server everytime  by shortcut, export android-frida=$(adb shell -n "su -c '/data/local/tmp/myserver &'")
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





function start_cooking(){

      base_dir='/tmp/android_pentest_ready'
      cd /tmp/
      rm -rf android_pentest_ready  2>/dev/null
      mkdir android_pentest_ready 2>/dev/null && cd android_pentest_ready 
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
            |  __ \                  /\             | |     / _ \ 
            | |__) |___ _ __ ______ /  \   _ __   __| |_ __| | | |
            |  ___// _ \  _ \______/ /\ \ |  _ \ / _  |  __| | | |
            | |   |  __/ | | |    / ____ \| | | | (_| | |  | |_| |
            |_|    \___|_| |_|   /_/    \_\_| |_|\__,_|_|   \___/ 
            '


            while IFS= read -r -n 1 -d '' c; do   printf '\e[38;5;%dm%s\e[0m'  "$((RANDOM%255+1))" "$c"; done <<<$bann0
}
function start(){
            banner
            echo -e "\033[0;37m"
            echo -e "\n1. All"
            echo "2. Android Apps(proxytoogle, proxydroid, ADBwifi)"
            echo "3. Pc Tools (JADX, frida, objection, Android Screen Control & Mirror "
            echo "4. Android Frida Server"
            echo "5. Fix Frida Server Version mismatch"
            echo "0. Exit "
            echo -e "\e[3$(( $RANDOM * 6 / 32767 + 1 ))m"
            echo -e 'I want to install  :-'
            read option && clear

            #Acting on the user input
            case $option in
            1) all
            ;;
            2) net; adb_check; andro_apps; banner
            ;;
            3) net; pc_tools;   
            ;;
            4) net; adb_check ;frida_ando banner
            ;;
            5) net; adb_check
            ;;
            0) banner;exit
            ;;
            esac 
            banner       

}

start_cooking

start
