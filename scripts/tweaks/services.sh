#!/bin/bash
#
# Description : Disable services with yes/no answer
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9 (13/Jan/18)
# Compatible  : Raspberry Pi 1, 2 & 3 (tested), ODROID-C1 (NOT tested)
#
# HELP	      · Package chkconfig to see daemon status
#
clear

. ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

check_board

services_ODROID(){

	# To disable on startup. Example: /etc/init/mysql.conf.bak

	# Check running services: initctl list | grep running
	echo -e "\nNTP (Network Time Protocol) daemon.\nTIP: Don't disable if you need time syncronization with internet."
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo systemctl disable ntp ;;
	esac

	echo -e "\nWhoopsie (Useless: Ubuntu Error Reporting daemon)."
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo systemctl disable whoopsie ;;
	esac

	echo -e "\nCups for manage printers."
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo systemctl disable cups && sudo systemctl disable cups-browsed ;;
	esac

	echo -e "\nBluetooth."
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo systemctl disable bluetooth ;;
	esac

	echo -e "\nAbout Desktop daemons\nDisable DBUS,Console Kit daemon\nTIP: Disable if you don't use desktop environment."
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo systemctl disable dbus ; sudo killall dbus-daemon ;;
	esac

	echo -e "\nKeyboard setup\n"
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo systemctl disable keyboard-setup ;;
	esac

	echo -e "\hdparm\nTIP: Useless if you don't use an external USB or HD device continuously"
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo systemctl disable hdparm ;;
	esac
}

services_RPi(){
	echo -e "\nNTP (Network Time Protocol) daemon.\nTIP: Don't disable if you need time syncronization with internet."
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) systemctl disable systemd-timesyncd.service ;;
	esac

	echo -e "\nTriggerhappy daemon\nTIP: Useless if you don't use keyboard keys like up/down volume, media keys..."
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo systemctl disable triggerhappy ;;
	esac

	echo -e "\nAbout Desktop daemons\nDisable DBUS,Console Kit daemon\nTIP: Disable if you don't use desktop environment."
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo systemctl disable dbus ; sudo killall dbus-daemon ;
	esac

	echo -e "\nKeyboard setup\n"
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo systemctl disable keyboard-setup ;;
	esac

	echo -e "\nRemove rsyslog (If you don't want to log files)\n"
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo systemctl disable rsyslog ;;
	esac
}

echo -e "Disable daemons (even on boot)\n==============================\n"
free -wth

if [[ ${MODEL} == 'Raspberry Pi' ]]; then
    services_RPi
elif [[ ${MODEL} == 'ODROID-C1' ]]; then
    services_ODROID
fi

free -wth
read -p "Have a nice day and don't blame me!. Press [Enter] to continue..."
