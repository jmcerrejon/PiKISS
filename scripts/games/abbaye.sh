#!/bin/bash
#
# Description : Abbaye des Morts v.2.0.0 SDL2
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.1 (17/Aug/20)
# Compatible  : Raspberry Pi 1-3 (?), 4 (tested)
#
# Help		  : https://misapuntesde.com/post.php?id=162
#

. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }
clear

BIN_PATH="https://misapuntesde.com/rpi_share/abbaye-des-morts_2-0_armhf.deb"

install() {
	if isPackageInstalled abbaye-for-linux-src; then
		echo -e "\nAbbaye des Morts is already installed.\n"
		return 0;
	fi
	echo -e "\nInstalling Abbaye des Morts, please wait..."
	if ! isPackageInstalled libsdl2-image-2.0-0; then
		sudo apt install -y libsdl2-image-2.0-0
	fi
	if ! isPackageInstalled libsdl2-mixer-2.0-0; then
		sudo apt install -y libsdl2-mixer-2.0-0
	fi
	wget -q -O /tmp/abbaye-des-morts_2-0_armhf.deb $BIN_PATH
	sudo dpkg -i /tmp/abbaye-des-morts_2-0_armhf.deb
	rm /tmp/abbaye-des-morts_2-0_armhf.deb
}

install

echo -e "\nType in a terminal abbayev2 or go to Start button > Games > Abbaye des Morts."
read -p "Press [ENTER] to go back to the menu..."
