#!/bin/bash
#
# Description : Re-Volt is a radio control car racing themed video game.
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.1 (08/Mar/20)
# Compatible  : Raspberry Pi 3-4 (tested on Raspberry Pi 4)
#
# HELP	      : Thanks to PI LAB (https://www.youtube.com/channel/UCgfQjdc5RceRlTGfuthBs7g) and Meverick
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

DATA_PATH='https://www.dropbox.com/s/i6puxhojyfro43d/rvgl-data.deb?dl=0'
APP_PATH='https://www.dropbox.com/s/eb1eh9oukyml5ii/rvgl.deb?dl=0'

installer(){
	sudo apt install -y libsdl2-image-2.0-0 libenet7 libunistring-dev
	fixlibGLES
	cd ~
	if [ ! -f /usr/local/bin/rvgl_start ]; then
		wget -O rvgl-data.deb $DATA_PATH
		wget -O rvgl.deb $APP_PATH
		sudo dpkg -i rvgl-data.deb rvgl.deb
		rm rvgl-data.deb rvgl.deb
	fi
}

echo -e "Installing Re-Volt...\n=====================\n\n· Please wait...\n"

installer

read -p "Done!. type rvgl_start to Play or go to Desktop Game Menu option. Follow the instructions to download game's data files. Press [ENTER] to continue..."
