#!/usr/bin/env bash
#
# Description : Easy install PiKISS
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.1 (05/Jul/20)
# TODO		  : Check the OS is Debian based.
clear

INSTALL_DIR="$HOME"
cd "$INSTALL_DIR"

if [ -d "$INSTALL_DIR/piKiss" ]; then
	cd "$INSTALL_DIR/piKiss" && ./piKiss.sh
	exit
fi

if [[ ! $(cat /proc/cpuinfo | grep 'BCM2708\|BCM2709\|BCM2835') ]]; then
	echo "Sorry. PiKISS is only for Raspberry Pi boards."
    exit
fi

echo -e "\nPiKISS\n======\nInstalling at $INSTALL_DIR/piKiss. Please wait...\n"
sudo apt install -y dialog
git clone https://github.com/jmcerrejon/PiKISS.git piKiss && cd "$_"
echo -e "\n\nPiKISS installed!. cd into $HOME/piKiss or go to Menu > System Tools > PiKISS\n"
read -p "Press ENTER to exit."
exit
