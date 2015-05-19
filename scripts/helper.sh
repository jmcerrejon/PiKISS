#!/bin/bash
#
# Description : Helpers functions
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
#
clear

check_board()
{
	if [[ $(cat /proc/cpuinfo | grep 'ODROIDC') ]]; then
		MODEL="ODROID-C1"
	elif [[ $(cat /proc/cpuinfo | grep 'BCM2708\|BCM2709') ]]; then
		MODEL="Raspberry Pi"
	elif [ $(uname -n) = "debian" ]; then
		MODEL="Debian"
	else
		MODEL="UNKNOWN"
		dialog --title '[ WARNING! ]' --msgbox "Board or Operating System not compatible.\nUse at your own risk." 6 45
	fi
}

SDL_fix_Rpi()
{
	echo "Applying fix to SDL on Raspberry Pi 2, please wait..."
	if [[ $(cat /proc/cpuinfo | grep 'BCM2709') && $(stat -c %y /usr/lib/arm-linux-gnueabihf/libSDL-1.2.so.0.11.4 | grep '2012') ]]; then
		wget -P /tmp http://malus.exotica.org.uk/~buzz/pi/sdl/sdl1/deb/rpi1/libsdl1.2debian_1.2.15-8rpi_armhf.deb
		sudo dpkg -i /tmp/libsdl1.2debian_1.2.15-8rpi_armhf.deb
		sudo rm /tmp/libsdl1.2debian_1.2.15-8rpi_armhf.deb
	fi
}

check_temperature()
{
 if [ -f /opt/vc/bin/vcgencmd ]; then
 	TEMPC="| $(/opt/vc/bin/vcgencmd measure_temp | awk '{print $1"º"}') "
 elif [ -f /sys/devices/virtual/thermal/thermal_zone0/temp ]; then
 	TEMPC="| TEMP: $(cat /sys/devices/virtual/thermal/thermal_zone0/temp | cut -c1-2 | awk '{print $1"º"}') "
 else
 	TEMPC=''
 fi
}

check_CPU()
{
 if [ -f /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq ]; then
 	CPU="| CPU Freq="`expr $(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq) / 1000`" MHz "
 else
 	CPU=''
 fi
}

check_internet_available()
{
# Make sure we have internet conection
if [ ! "$NOINTERNETCHECK" = 1 ]; then
	PINGOUTPUT=$(ping -c 1 8.8.8.8 > /dev/null && echo 'true')
	if [ ! "$PINGOUTPUT" = true ]; then
		echo "Internet connection required. Check your network."; exit 1
	fi
fi
}

show_dialog()
{
	local h=${1-10}			# box height default 10
	local w=${2-41} 		# box width default 41
	local t=${3-Output} 	# box title 

	while true
do

	dialog --clear   \
		--title		"[ M A I N - M E N U ]" \
		--menu 		"You can use the UP/DOWN arrow keys, the first letter of the choice as a hot key, or the number keys 1-4 to choose an option." ${h} ${w} \
		"$(<$OUTPUT)" 
		Exit 		"Exit to the shell" 2> "$(<$INPUT)" 

	menuitem=$(<"${INPUT}")

	case $menuitem in
		Tweaks)	    	smTweaks ;;
		Games) 	    	smGames ;;
	        Emula)	    	smEmulators ;;
		Info)	    	smInfo ;;
		Multimedia) 	smMultimedia ;;
		Configure)  	smConfigure ;;
		Internet)   	smInternet ;;
		Server)     	smServer ;;
		Others)     	smOthers ;;
		Exit) 	    	echo -e "\nThanks for visiting http://misapuntesde.com" && exit ;;
1)
    echo -e "\nCancel pressed." && exit;;
  255)
    echo -e "\nESC pressed." && exit;;
	esac
done
}

mkDesktopEntry(){
	if [[ ! -e /usr/share/applications/pikiss.desktop ]]; then
		sudo sh -c 'echo "[Desktop Entry]\nName=PiKISS\nComment=A bunch of scripts with menu to make your life easier\nExec='$PWD'/piKiss.sh\nIcon=terminal\nTerminal=true\nType=Application\nCategories=ConsoleOnly;Utility;System;\nPath='$PWD'/" > /usr/share/applications/pikiss.desktop'
		# if [[ -e ./piKiss.sh ]]; then
		# 	sed -i -e 's/mkDesktopEntry/#mkDesktopEntry/ig' ./piKiss.sh
		# fi
	fi
}

validate_url(){
    if [[ `wget -S --spider $1 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then echo "true"; fi
}
