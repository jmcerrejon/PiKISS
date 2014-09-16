#!/bin/bash
#
# Description : Synergy client allow you to share one keyboard and mouse to computers on LAN
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (16/Sep/14)
#  
clear
IP_RANGE=$(/sbin/ip route | awk '/default/ { print $3 }' | sed 's/\.[0-9]*$//')
SERVER_IP='SERVER_IP'
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/mnuopt$$

trap "rm -f $tempfile" 0 1 2 5 15

CHOOSE_IP(){
	echo -e "\nScanning LAN, please wait..."
	OPTION=$(echo $IP_RANGE.{1..254}|xargs -n1 -P0 ping -c1|grep "bytes from" | tr -d ':' | awk '{print $4" IP"}')
	# for i in {1..254} ;do (ping 192.168.1.$i -c 1 -w 5  >/dev/null && echo "192.168.1.$i" &) ;done
	#| cut -d ":" -f 1

	dialog --title     '[ Synergy Server ]' --clear \
       --menu      "Choose Synaptic Server IP from your LAN:" 10 55 10 $OPTION 2>"${tempfile}"
   
	SERVER_IP=$(<"${tempfile}")
}

RUN_ON_BOOT(){
	dialog  --title     '[ Synergy Server ]' \
        --yes-label "Yes" \
        --no-label  "No" \
        --yesno     "Do you want to run Synergy Client on boot?" 5 46

response=$?
case $response in
   0) sudo sed -i '$i synergyc --daemon '"${SERVER_IP}" /etc/rc.local;;
   1) clear ; echo "You choose NOT to run on boot...";;
   255) echo "[ESC] key pressed.";;
esac
}

echo -e "Installing Synergy...\n=====================\n · Synergy allow you to share one keyboard and mouse to computers on LAN.\n · You need PC with a Synergy Server."

whereis -B "/usr/sbin" "/usr/local/sbin" "/sbin" "/usr/bin" "/usr/local/bin" "/bin" -b synergyc | grep -i "/synergyc" > /dev/null 2>&1
repro_instalado=$?
	if [ $repro_instalado -eq 1 ]; then
		sudo apt-get install -y synergy
	else
		read -p " · Synergy already installed!. Continue? [y/n] " optionhgh
			case "$option" in
			    n*) read -p "Press [ENTER] To Continue..." ; exit ;;
			esac
	fi

CHOOSE_IP
RUN_ON_BOOT

echo -e "\nDone! Type: synergyc --daemon $SERVER_IP to run manually on Desktop."
read -p "Press [ENTER] To Continue..."