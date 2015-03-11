#!/bin/bash
#
# Description : Disable services with yes/no answer
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.5 (10/Mar/15)
#
# HELP	      · Package chkconfig to see daemon status
#
clear

. ../helper.sh || . ./scripts/helper.sh ||
    { clear && echo "ERROR : ./script/helper.sh not found." && exit 1 ;}

check_board

services_ODROID(){

	# To disable on startup. Example: /etc/init/mysql.conf.bak

	# Check running services: initctl list | grep running
	echo -e "\nNTP (Network Time Protocol) daemon.\nTIP: Don't disable if you need time syncronization with internet."
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo update-rc.d ntp disable ;;
	esac

	echo -e "\nWhoopsie (Useless: Ubuntu Error Reporting daemon)."
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo service whoopsie stop ;; 
	esac

	echo -e "\nCups for manage printers."
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo service cups stop && sudo service cups-browsed stop ;; 
	esac

	echo -e "\nBluetooth."
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo service bluetooth stop ;; 
	esac

	echo -e "\nAbout Desktop daemons\nDisable DBUS,Console Kit daemon\nTIP: Disable if you don't use desktop environment."
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo update-rc.d dbus disable ; sudo update-rc.d console-kit-daemon disable ; sudo killall dbus-daemon ; sudo killall dbus-launch ;;
	esac

	# echo -e "\nCups/Sane\nTIP: Useless if you don't use printer or scanner"
	# read -p "Disable? [y/n] " option
	# case "$option" in
	#     y*) sudo update-rc.d cups disable ; sudo update-rc.d saned disable ;; 
	# esac

	echo -e "\nPlymouth\nTIP: Boot animation"
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo update-rc.d plymouth disable ; sudo update-rc.d plymouth-log disable ;; 
	esac

	echo -e "\nKeyboard setup\n"
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo update-rc.d keyboard-setup disable ;; 
	esac

	echo -e "\hdparm\nTIP: Useless if you don't use an external USB or HD device continuously"
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo update-rc.d hdparm disable ;; 
	esac
}

services_RPi(){
	echo -e "\nNTP (Network Time Protocol) daemon.\nTIP: Don't disable if you need time syncronization with internet."
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo update-rc.d ntp disable ;;
	esac

	echo -e "\nTriggerhappy daemon\nTIP: Useless if you don't use keyboard keys like up/down volume, media keys..."
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo update-rc.d triggerhappy disable ;; 
	esac

	echo -e "\nAbout Desktop daemons\nDisable DBUS,Console Kit daemon\nTIP: Disable if you don't use desktop environment."
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo update-rc.d dbus disable ; sudo update-rc.d console-kit-daemon disable ; sudo killall dbus-daemon ; sudo killall dbus-launch ;;
	esac

	# echo -e "\nCups/Sane\nTIP: Useless if you don't use printer or scanner"
	# read -p "Disable? [y/n] " option
	# case "$option" in
	#     y*) sudo update-rc.d cups disable ; sudo update-rc.d saned disable ;; 
	# esac

	echo -e "\nPlymouth\nTIP: Boot animation"
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo update-rc.d plymouth disable ; sudo update-rc.d plymouth-log disable ;; 
	esac

	echo -e "\nKeyboard setup\n"
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo update-rc.d keyboard-setup disable ;; 
	esac

	echo -e "\hdparm\nTIP: Useless if you don't use an external USB or HD device continuously"
	read -p "Disable? [y/n] " option
	case "$option" in
	    y*) sudo update-rc.d hdparm disable ;; 
	esac
}

echo -e "Disable daemons (even on boot)\n==============================\n"
free -h

if [[ ${MODEL} == 'Raspberry Pi' ]]; then
    services_RPi
elif [[ ${MODEL} == 'ODROID-C1' ]]; then
    services_ODROID
fi

read -p "Have a nice day and don't blame me!. Press [Enter] to continue..."