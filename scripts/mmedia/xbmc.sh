#!/bin/bash
#
# Description : Install XBMC - Kodi
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (13/Jul/20)
# Compatible  : Raspberry Pi 1-4
#
# TODO	      [ ] Ask user if want to start Kodi from boot.
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

uninstall() {
	read -p "Do you want to uninstall Kodi (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		sudo apt remove -y kodi
		sudo apt -y autoremove
	fi
	exitMessage
}

if [[ -e /usr/bin/kodi ]]; then
	echo -e "Kodi already installed.\n"
	uninstall
	exit 1
fi

runNow() {
	echo
	read -p "Do you want to run Kodi right now (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		kodi
	fi
	exitMessage
}

install() {
	sudo apt-get update
	sudo apt-get install -y kodi
	sudo usermod -a -G "audio,video,input,dialout,plugdev,tty" $USER
	sudo addgroup --system input
	echo -e "\nDone. Go to Menu > Sound & Video or type kodi to run."
	runNow
}

echo -e "Installing KODI (from repo)...\n"
install
