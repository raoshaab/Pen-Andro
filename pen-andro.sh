#!/bin/bash 
#Author: @github.com/raoshaab
#############Checking for pre-condition###########
#Want to learn adb in easy way 
# https://adbshell.com/


#for Burpsuite

function burp(){
      default_ip='127.0.0.1:8080'
      check=$(curl -s http://${default_ip}/ 2>/dev/null  |grep Burp -o|head -n1)

      if [[ $check == Burp ]]
      then 
            echo "+------------------------------------------+"
            echo "|                                          |"
            echo "|         Burpsuite Running done !!        |"
            echo -e "+------------------------------------------+\n\n"
            

      
      else
            echo -e "\033[1;91m" 
            echo "+----------------------------------------------- +"
            echo "|                  Error                         |" 
            echo "| Burpsuite proxy not running at(127.0.0.1:8080) |" 
            echo -e "+-----------------------------------------------+\n\n" 
      
      #To enter other Ip address and port 
       
            echo "Enter the Burpsuite Ip and port i.e 192.168.1.1:9001" 
            read proxy

            check=$(curl -s ${proxy} 2>/dev/null  |grep Burp -o|head -n1)
            if [[ $check == Burp ]]
            then 
                  echo "+------------------------------------------+"
                  echo "|                                          |"
                  echo "|         Burpsuite Running done !!        |"
                  echo -e "+------------------------------------------+\n\n"
                  set default_ip=${proxy}

            
            else
                  echo -e "\033[1;91m" 
                  echo "+------------------------------------------------+"
                  echo "|                  Error                         |" 
                  echo "| Burpsuite proxy not running at (${proxy})|" 
                  echo -e "+---------------------------------------------+\n\n" && banner && exit
            fi
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
            echo "|     More than one emulator exits         |" 
            echo "|     Check with command adb deivces       |"
            echo "|   To restart adb server adb kill-server  |"
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
            echo "|                                          |"
            echo -e "+------------------------------------------+\n\n"
            install_magisk && banner && exit
      fi

        

}


#====================================================================Before Starting ===================================================================
#https://github.com/whalehub/custom-certificate-authorities
#https://pswalia2u.medium.com/install-burpsuites-or-any-ca-certificate-to-system-store-in-android-10-and-11-38e508a5541a
###############  Moving Certificate for android via adb -----------------------------------
function burpcer(){ 
      
      #changing directory for tmp files download
      cd ${tmp_dir}
      cert_check=$(adb shell 'su -c "ls /system/etc/security/cacerts|grep 9a5ba575.0"')
      res='y'
      #checking existing Burpsuite certificate
      if [[ "$cert_check" == "9a5ba575.0" ]]
      then 
            echo -e "\033[1;91m" 
            echo -e "Already Burpsuite Certificate found, this will replace existing one\n"
            
            echo -e "\033[0;92mIf you want to replace it press Y if not then N/n " 
            read res
      
      fi
      
      if [[ $res == 'N' || $res == 'n' ]]
      then  
            echo 'No changes in Burp Certificate '
      elif [[ $res == 'Y' || $res == 'y' ]] ;then 
            wget --quiet  ${default_ip}/cert -O cacert.der 
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
            echo "adb reboot &"
            echo "Enter the command adb reboot or manual reboot "

      fi
}

#All Apps 
############### Proxy toggle----------------------- 
function andro_apps(){
      #changing directory for tmp files download
      cd ${tmp_dir}
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
      #changing directory for tmp files download
      cd ${tmp_dir}

      #frida
      magisk_version=$(curl -IkLs -o /dev/null -w %{url_effective}  https://github.com/ViRb3/magisk-frida/releases/latest|grep -o "[^/]*$"| sed "s/v//g")
      baseurl="https://github.com/ViRb3/magisk-frida/releases/download/$magisk_version/MagiskFrida-$magisk_version.zip"
      echo '      Downloading Module .....'
      wget --quiet $baseurl -O frida_module.zip
      adb push frida_module.zip /data/local/tmp/ >/dev/null 2>&1
      echo '      Flashing MagsikFrida .......'
      echo -e '\n\n    ********************************************
    *               MagiskFrida                *
    ********************************************'
      adb shell -n "su -c  'magisk  --install-module /data/local/tmp/frida_module.zip' " >/dev/null 2>&1

      #trust 
      wget -q https://github.com/NVISOsecurity/MagiskTrustUserCerts/releases/download/v0.4.1/AlwaysTrustUserCerts.zip -O trust_module.zip
      adb push   trust_module.zip /data/local/tmp  >/dev/null 2>&1
      adb shell -n "su -c  'magisk  --install-module /data/local/tmp/trust_module.zip'" >/dev/null 2>&1

      echo "Frida Module installed on Device"


}

function frida_manual(){
      #changing directory for tmp files download
      cd ${tmp_dir}

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
      adb shell -n "su -c 'mv /data/local/tmp/frida-server /system/xbin/frida-server'"
      echo 'Frida Server copied  to Android system'

      echo "+------------------------------------------+"
      echo "|                                          |"
      echo "|  Setup Ready  with Android frida         |"
      echo -e "+------------------------------------------+\n\n\n"
      echo "To Check version of frida server ,run command "
      echo -e "adb shell -n \"su -c 'frida-server --version'\"\n\n\n"
      echo "To run the frida-sever run below command "
       echo -e "adb shell -n \"su -c 'frida-server '\"\n\n\n"
      
}

function frida_ando(){
      #Checking for frida-server in android 
      echo "frida_ando function"
      frida_android=$(adb shell "frida-server --version" 2>/dev/null )
      check=$(echo $frida_android |cut -d '.' -f1 )
      echo $check waiting here  
      sleep 100
      if [ $check -n ]
      then 
            echo -e "\033[1;91mFrida-server already Installed with version ${frida_android} \n\n \033[0;92mIf you want to upgrade or reinstall Press Y/y "
            read res     
            if [[ $res == 'Y' || $res == 'y' ]]
            then 
                  magisk_version=$(adb shell "magisk -v|cut -d ':' -f2" 2>/dev/null)
                  if [[ $magisk_version == "MAGISK" ]]
                  then  
                  #magisk  will flash frida server module which autostart on reboot
                        magisk_module
                  else 
                        frida_manual
                  fi
            else     
                  echo 'Frida-server already Installed'  
            fi 

      elif [ $check -z ]
      then  
            magisk_version=$(adb shell "magisk -v|cut -d ':' -f2" 2>/dev/null)
            if [[ $magisk_version == "MAGISK" ]]
            then  
            #magisk  will flash frida server module which autostart on reboot
                  magisk_module
            else 
            #downloading frida-server from source 
                  frida_manual
            fi 
      else
            echo function not working 
      fi
}


## To install magisk in Genymotion 
#will add this in future 
function install_magisk(){
# if device ==genymotion 
# then 
#adb push magisk.zip /sdcard/
#adb shell "/system/bin/flash-archive.sh /sdcard/magisk.zip"

echo -e "Check For Genymotion  https://tinyurl.com/magisk-genymotion"
echo -e "Check For Android Virtual Device AVD https://tinyurl.com/magisk-avd"
echo -e "Check For Physical Device => Search <Device-name> magisk xda on Google"

}


#frida version mismatch

function frida_mismatch(){
      lat_frida_version=$(curl -IkLs -o /dev/null -w %{url_effective}  https://github.com/frida/frida/releases/latest|grep -o "[^/]*$"| sed "s/v//g")
      
      pc_version=$(frida --version 2>/dev/null )
      android_version=$(adb shell -n 'sh -c "/data/local/tmp/frida-server --version"'  2>/dev/null)

      echo -e " Latest Version  => ${lat_frida_version} \n Pc version      => ${pc_version} \n Android Version => ${android_version}"

      if [[ ${pc_version} != ${android_version} ]]
      then 
                  
            if [[ ${lat_frida_version} != ${pc_version} ]]
            then 

                  echo -e "\n\tPc Version is outdated\n"
                  echo "Downloading latest version ......."
                  pip3 install frida  --upgrade  &>/dev/null 
                  echo -e "\n\nLatest version installed $(frida --version)"
            elif [[ ${lat_frida_version} != ${android_version} ]]
            then 
                  frida_android 
            fi
      elif [[ ${android_version} == ${pc_version} ]] 
      then 
            echo -e "\n\n Same Version in Android (${android_version}) and Pc (${pc_version})"  
      fi
      
}


function all(){

      net 
      burp
      adb_check
      pc_tools
      andro_apps
      frida_ando
      burpcer
      apk_tools_download

      echo "Reboot Android device to reflect changes"
      #adb reboot

}

function apk_tools_download(){

      #changing directory to tools 
      cd $tools_dir
      ls 
      if [ ! -f apk-editor.jar ] 
      then 
            #apk editor
            version=$(curl -IkLs -o /dev/null -w %{url_effective}  https://github.com/REAndroid/APKEditor/releases/latest|grep -o "[^/]*$"| sed "s/V//g")
            base_url="https://github.com/REAndroid/APKEditor/releases/download/V${version}/APKEditor-${version}.jar"
            wget --quiet $base_url -O  apk-editor.jar
            apk_merge="java -jar ${tools_dir}/apk-editor.jar m -i $1 -o $2"  
      else 
            echo "Tools available" 
      fi
      if [ ! -f uber-sign-apk.jar ]
      then  
      #apk signer
            version=$(curl -IkLs -o /dev/null -w %{url_effective}  https://github.com/patrickfav/uber-apk-signer/releases/latest|grep -o "[^/]*$"| sed "s/v//g")
            base_url="https://github.com/patrickfav/uber-apk-signer/releases/download/v${version}/uber-apk-signer-${version}.jar"
            wget --quiet $base_url -O   uber-sign-apk.jar
            apk_sign="java -jar ${tools_dir}/uber-sign-apk.jar"
      else 
            echo "Tools available"
      fi


}

function apk_pull(){
      #java check
      version=$(java --version 2>/dev/null)

      if [[ $? == 127 ]]
      then 
        echo "Java is not Installed" && exit
      fi 

      echo 'Enter name of App which you want to pull'
      read name_app

      app_name=$(adb shell 'pm list packages' | sed 's/.*://g'|grep "${name_app}")
      echo "Got a exact match ${app_name}"
      app_path=$(adb shell pm path ${app_name}|sed 's/.*://g')


      NUM_APK=`echo "$app_path" | wc -l`
      apk_merge="java -jar ${tools_dir}/apk-editor.jar m -i "	
      apk_sign="java -jar ${tools_dir}/uber-sign-apk.jar"

      if [ $NUM_APK -gt 1 ]; then
                  
                  mkdir "${app_name}_apks" 
                  echo "apk Pulling from device Starts...."
                  adb pull ${app_path} "${app_name}_apks" 2>/dev/null
                  echo "Apk pulled Complete, Combine starts"
                  
                  $apk_merge "${app_name}_apks" -o ${app_name}1.apk 2>/dev/null
                  echo "Merge Complete"

                  $apk_sign -a ${app_name}1.apk -o ${app_name}.apk 2>/dev/null
                  echo "Signing the app starts ..."
                  mv  ${app_name}-aligned-debugSigned.apk ${app_name}.apk 
                  rm ${app_name}1.apk -rf "${app_name}_apks"
                  mv ${app_name}.apk ${HOME}/
                  echo "${app_name}.apk  is Ready in ${HOME}/ Directory"  


      else 
            adb pull ${app_path} ${HOME}/${app_name} 2>/dev/null
            echo "${app_name}.apk  is Ready in ${HOME}/ Directory"  

      fi

}

################ All neccesary functions must defined above ###################

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
            tools_dir="${PWD}/.local/share/android_pentest_ready"
            tmp_dir='/tmp/android_pentest_ready'
            mkdir ${tools_dir} >/dev/null 2>&1
            mkdir ${tmp_dir} >/dev/null 2>&1 
            cd ${tmp_dir} 
  
            echo -e "\033[0;37m"
            echo -e "\n1. All"
            echo "2. Move Burpsuite Certificate to Android root folder"
            echo "3. Pc Tools (JADX, frida, objection, scrcpy) "
            echo "4. Android Frida Server"
            echo "5. Fix Frida Server Version mismatch"
            echo "6. Android Apps(proxytoogle, proxydroid, ADBwifi)"
            echo "7. Pull Apk from device "
            echo "0. Exit "
            echo -e "\e[3$(( $RANDOM * 6 / 32767 + 1 ))m"
            echo -e "I want to install  :-"
            read option
            

            #Acting on the user input
            case $option in
            1) all
            ;;
            2) net; adb_check;burp;burpcer
            ;;
            3) net; pc_tools;   
            ;;
            4) net && adb_check && frida_ando
            ;;
            5) net; adb_check;frida_mismatch;
            ;;
            6) net; adb_check; andro_apps
            ;;
            7) net; adb_check; apk_tools_download; apk_pull
            ;;
            0) banner;exit
            ;;
            esac 
            start       

}

start