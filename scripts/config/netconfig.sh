#!/bin/bash
# read https://stackoverflow.com/questions/8794888/bash-scripting-how-to-get-item-name-on-a-radiolist-using-dialog
# read https://stackoverflow.com/questions/4889187/dynamic-dialog-menu-box-in-bash
# https://www.howtogeek.com/167425/how-to-setup-wi-fi-on-your-raspberry-pi-via-the-command-line/
# https://www.cromwell-intl.com/linux/raspberry-pi/networking.html
# https://www.bot-thoughts.com/2013/01/raspberry-pi-wifi-static-ip.html#.Ui843qzMTIo
# https://elinux.org/images/4/4b/Raspberry_Pi_wireless_adapter.pdf

# Root priviledges
if [ $(/usr/bin/id -u) -ne 0 -a $NOROOT = 0 ]; then echo "Please run as root."; exit 1; fi

adapter='eth0'
devices=$(cat /proc/net/dev | egrep 'eth|wlan' | sed 's/://g' | awk '{print $1,$1}')
interfacefile='/etc/network/interfaces'
dns_string=''
title2=''
wpa_sup=''
modify=0
both=0
declare -a arrNetwork=(
  "$(cat $interfacefile | grep 'address' | awk '{print $2}')" # IP
  "$(ifconfig $adapter | sed -rn '2s/ .*:(.*)$/\1/p')" #NetMask
  "$(/sbin/ip route | awk '/default/ { print $3 }')" # Gateway
  "8.8.8.8" # DNS
)
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$

trap "rm -f $tempfile" 0 1 2 5 15

writeinterfacefile()
{
  FILE="\n
  auto lo\n
  iface lo inet loopback\n
  \n
  auto $adapter\n
  iface $adapter inet static\n
  address ${arrNetwork[0]}\n
  netmask ${arrNetwork[1]}\n
  gateway ${arrNetwork[2]}\n
  $wpa_sup\n
  $dns_string\n
  "

  echo -e $FILE > ./interfaces.pre
}

addInterfaceFile()
{
  FILE="\n
  auto lo\n
  iface lo inet loopback\n
  \n
  auto $adapter\n
  iface $adapter inet static\n
  address ${arrNetwork[0]}\n
  netmask ${arrNetwork[1]}\n
  gateway ${arrNetwork[2]}\n
  $wpa_sup\n
  $dns_string\n
  "

  echo $FILE >> ./interfaces.pre
}

writewpa_supplicant()
{
  FILE="
    ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\n
    update_config=1\n
    \n
    network={\n
    # There must be quotes around the SSID and PSK\n
    ssid=\"YOURSSID\"\n
    psk=\"YOURPASSWORD\"\n
    \n
    # Protocol type can be: RSN (for WPA2) and WPA (for WPA1)\n
    proto=WPA\n
    \n
    # Key management type can be: WPA-PSK or WPA-EAP (Pre-Shared or Enterprise)\n
    key_mgmt=WPA-PSK\n
    \n
    # Pairwise can be CCMP or TKIP (for WPA2 or WPA1)\n
    pairwise=TKIP\n
    \n
    #Authorization option should be OPEN for both WPA1/WPA2 (in less commonly used are SHARED and LEAP)\n
    auth_alg=OPEN\n
    }
  "

  echo -e $FILE > ./wpa_supplicant.conf.pre
}

# Run if we have more than one device
if [[ $(cat /proc/net/dev | egrep 'eth|wlan' | wc -l) = 2 ]]; then
  devices="$devices both Both!"
  dialog --backtitle "$TITLE" \
         --title     '[ Configure static IP ]' --clear \
         --menu      "Please choose a network device:" 15 55 5 $devices 2>"${tempfile}"
   
  adapter=$(<"${tempfile}")
  title2="[ Configure static IP on $adapter]"
fi

if [[ ${arrNetwork[0]} != "" ]]; then
  dialog --backtitle "$TITLE" \
         --title     "$title2" \
         --yes-label "Modify" \
         --no-label  "Overwrite" \
         --yesno     "You have a static IP already configured. Do you want to modify it?\nPress [ESC] to Cancel." 7 55
   
  retval=$?

  case $retval in
    0)   modify=1; break ;;
    1)   modify=0; break ;;
    255) exit ;;
  esac
fi

# open fd
exec 3>&1

FORM=$(dialog --backtitle "$TITLE" \
	            --title     "$title2" \
	            --form      "Please fill the next info.\nLeave DNS field blank if you want automatic DHCP" 15 50 0 \
            	"IP:"      1 1 "${arrNetwork[0]}" 1 16 15 0 \
            	"Mask:"    2 1 "${arrNetwork[1]}" 2 16 15 0 \
            	"Gateway:" 3 1 "${arrNetwork[2]}" 3 16 15 0 \
            	"DNS:"     4 1 "${arrNetwork[3]}" 4 16 15 0 2>&1 1>&3)

# close fd
exec 3>&-

# split $FORM and initialize arrNetwork with new values
arrNetwork=(${FORM// / })

# check some values on arrNetwork
[[ ${arrNetwork[3]} = "" ]] && dns_string='iface default inet dhcp' || dns_string="dns-nameservers ${arrNetwork[3]}"

#Improve this
for i in "${arrNetwork[@]}"
do
  [[ $i =~ [[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3} ]] || echo "'$i' is not a valid IP"
done

if [[ $modify = 1 ]]; then
  $(sed -i "s/.*address.*/ address ${arrNetwork[0]}/" $interfacefile && sed -i "s/.*netmask.*/ netmask ${arrNetwork[1]}/" $interfacefile && sed -i "s/.*gateway.*/ gateway ${arrNetwork[2]}/" $interfacefile)
  # If you want automatic dns...
  [[ ${arrNetwork[3]} != "" && "cat $interfacefile | grep 'dns-nameservers'" != "" ]] && $(sed -i "s/.*dns-nameservers.*/ dns-nameservers ${arrNetwork[3]}/" $interfacefile)
else
  # Create the interfaces.pre
  [[ $(echo $adapter | cut -c -4) = "wlan" ]] && wpa_sup='wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf'

  writeinterfacefile

  # Create the interfaces.pre
  if [ ! -e /etc/wpa_supplicant/wpa_supplicant.conf ]; then
    writewpa_supplicant

    dialog --backtitle "$TITLE" \
             --title   "$title2" \
             --yesno   "I see you don't have the file /etc/wpa_supplicant/wpa_supplicant.conf\nI created it for you. Do you want to modify manually according to your settings?\n[ESC] twice to Exit and discard changes." 10 50

      retval=$?

      case $retval in
        0)   nano ./wpa_supplicant.conf.pre ;;
        255) exit ;;
      esac
  fi

  if [[ ${arrNetwork[0]} != "" ]]; then
    dialog --backtitle "$TITLE" \
           --title     "$title2" \
           --yes-label "View" \
           --no-label  "Edit" \
           --yesno     "Saved!. Do you wat to view or edit with nano the file interfaces before submit changes?\n[ESC] twice to Exit and discard changes" 10 50

    retval=$?

    case $retval in
      0)   dialog --textbox ./interfaces.pre 20 40 ;;
      1)   nano ./interfaces.pre ;;
      255) exit ;;
    esac
  fi

fi
#exit
# backup, copy file and test connection
file_backup "$interfacefile"
[ -e ./interfaces.pre ] && cp ./interfaces.pre $interfacefile
[ -e ./wpa_supplicant.conf.pre ] && cp ./wpa_supplicant.conf.pre /etc/wpa_supplicant/wpa_supplicant.conf
[ -e /etc/init.d/networking ] && sudo /etc/init.d/networking restart

if ! ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null;then 
  echo "Something is wrong. Reloading the network interface..."
  sudo /etc/init.d/networking reload
  echo "Reloaded. If problem persist, reboot your system. A backup file was made before changes called interfaces.pre"
  exit 1
else
  #delete garbage if OK
  [ -e ./interfaces.pre ] && rm -f ./interfaces.pre
  [ -e ./wpa_supplicant.conf.pre ] && rm -f ./wpa_supplicant.conf.pre
fi