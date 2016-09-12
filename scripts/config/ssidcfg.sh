#!/bin/bash
#
# Description : SSID Config (WPA/WPA2 with PSK)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1 (12/Sep/16)
#
clear

echo "Searching SSID..."

DATA=$(tempfile 2>/dev/null)
# TODO: Get wlan of your board
#WLAN=$(egrep 'wlan' /proc/net/dev | sed 's/://g' | awk '{print $1}')
WLAN='wlan0'

sudo iwlist wlan0 scan > /tmp/wifiscan

[ -f /tmp/ssids ] && rm /tmp/ssids

n_results=$(grep -c "ESSID:" /tmp/wifiscan)
i=1

while [ "$i" -le "$n_results" ]; do
        if [ $i -lt 10 ]; then
                cell=$(echo "Cell 0$i - Address:")
        else
                cell=$(echo "Cell $i - Address:")
        fi
        j=`expr $i + 1`
        if [ $j -lt 10 ]; then
                nextcell=$(echo "Cell 0$j - Address:")
        else
                nextcell=$(echo "Cell $j - Address:")
        fi
        awk -v v1="$cell" '$0 ~ v1 {p=1}p' /tmp/wifiscan | awk -v v2="$nextcell" '$0 ~ v2 {exit}1' > /tmp/onecell #store only one cell info in a temp file

        onessid=$(grep "ESSID:" /tmp/onecell | egrep 'ESSID' | sed 's/ESSID://g;s/"//g' | awk '{print $1}')
        oneencryption=$(grep "Encryption key:" /tmp/onecell | awk '{ sub(/^[ \t]+/, ""); print }' | awk '{gsub("Encryption key:on", "(secure)");print}' | awk '{gsub("Encryption key:off", "(open)");print}')
        onepower=$(grep "Quality=" /tmp/onecell | awk '{ sub(/^[ \t]+/, ""); print }' | awk '{gsub("Quality=", "");print}' | awk -F '/70' '{print $1}')
        onepower=$(awk -v v3=$onepower 'BEGIN{ print v3 * 10 / 7}')
        onepower=${onepower%.*}
        onepower="(Signal:$onepower%)"

        echo "$onessid $oneencryption$onepower" >> /tmp/ssids

        i=`expr $i + 1`
done

SSID=$(cat /tmp/ssids)

# [ -f /tmp/onecell ] && rm /tmp/onecell
# [ -f /tmp/ssids ] && rm /tmp/ssids
# [ -f /tmp/wifiscan ] && rm /tmp/wifiscan

# trap it
trap 'rm -f $DATA' 0 1 2 5 15

dialog --title     '[ SSID Configurator (WPA/WPA2 with PSK) ]' --clear \
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
  sudo cp /etc/wpa_supplicant/wpa_supplicant.conf{,.pre}
fi

echo -e "country=GB\nctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\nupdate_config=1\nnetwork={\n    ssid=\"$SSIDCHOSEN\"\n    psk=\"$PSWD\"\n}\n" | sudo tee /etc/wpa_supplicant/wpa_supplicant.conf

clear
# sudo ifdown wlan0
# sudo ifup wlan0

echo -e "Done!. Backed up/Modified wpa_supplicant.conf. Please reboot to changes take effect."
read -p "Press [ENTER] to continue..."
