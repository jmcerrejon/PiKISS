#!/bin/bash
#
# Description : Config your wlan0 device (WPA/WPA2 with PSK)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9 (09/Aug/14)
#
# TODO:       · Ask if you have more than one wlan
#
# HELP        · PI: sudo iwlist wlan0 scanning  | egrep 'ESSID' | sed 's|[ESSID:"]||g'
#             · UBUNTU: sudo iw wlan0 scan | egrep 'SSID' | sed 's/://g' | awk '{print $1, $2}'
#             · http://www.dafinga.net/2013/01/how-to-setup-raspberry-pi-with-hidden.html
#             · https://learn.adafruit.com/adafruits-raspberry-pi-lesson-3-network-setup/setting-up-wifi-with-occidentalis
#             · http://www.howtogeek.com/167425/how-to-setup-wi-fi-on-your-raspberry-pi-via-the-command-line/
clear

if [[ ! -e /usr/bin/wpa_passphrase ]]; then
  sudo apt-get install -y wpasupplicant wireless-tools
fi

DATA=$(tempfile 2>/dev/null)
WLAN="wlan0"

echo "Searching SSID..."

DEVICE=$(egrep 'wlan' /proc/net/dev | sed 's/://g' | awk '{print $1, $1}')
#if [! -e '/usr/bin/lsb_release'] || [ $(lsb_release -si) == 'Ubuntu' ]; then
SSID=$(sudo iwlist wlan0 scanning  | egrep 'ESSID' | sed 's/ESSID://g;s/"//g' | awk '{print $1, "SSID"}')

if [ -z "$SSID" ]; then
  clear ; echo "There is no wifi adapter or is down. Exiting...";exit
fi

# trap it
trap "rm -f $DATA" 0 1 2 5 15

dialog --title     '[ WLAN Configurator (WPA/WPA2 with PSK) ]' --clear \
     --menu      "Please choose your wlan SSID.\nESC twice to EXIT:" 15 55 5 $SSID 2>"$DATA"
ret=$?
 
case $ret in
  0)
    SSIDCHOSEN=$(<"$DATA");;
  1)
    echo -e "\nCancel pressed." && exit;;
  255)
    echo -e "\nESC pressed." && exit;;
esac

dialog --insecure --passwordbox "Enter your password (Between 8-63 characters):" 8 50 2>"$DATA"
ret=$?
 
case $ret in
  0)
    PSWD=$(<"$DATA");;
  1)
    echo -e "\nCancel pressed." && exit;;
  255)
    echo -e "\nESC pressed." && exit;;
esac

if [ -z "$SSIDCHOSEN" ] || [ -z "$PSWD" ]; then
  echo "Some variable is empty. Exiting..."
  exit
fi

if [[ ! -e '/etc/wpa_supplicant/wpa_supplicant.conf.pre' ]]; then
  $(sudo cp /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.pre)
fi

# Ugly way to check if not Raspbian. Change it NOW!
if [[ -e '/usr/bin/lsb_release' ]]; then
  nmcli d disconnect iface ${WLAN}
  clear ; echo "Connecting, please wait..."
  nmcli d wifi connect ${SSIDCHOSEN} password ${PSWD} iface ${WLAN}
else
  echo "Desconnecting wired network eth0..."
  #sudo ifconfig eth0 down
  echo "Connecting, please wait..."
  wpa_passphrase ${SSIDCHOSEN} ${PSWD} | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf
  sudo dhclient -v "${WLAN}"
fi

PINGOUTPUT=$(ping -c 1 8.8.8.8 > /dev/null && echo 'true')
if [ "$PINGOUTPUT" = true ]; then
  echo -e "Done!. Backup & Modified wpa_supplicant.conf. Please reboot to changes take effect."
else
  echo -e "Something is wrong. Backup & Modified wpa_supplicant.conf. Please reboot and try again."
fi

