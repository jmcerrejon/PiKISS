#!/usr/bin/env bash
#
# Description : Easy install PiKISS
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (22/Jun/20)
# TODO		  : Check the OS is Debian based.
clear

INSTALL_DIR="$HOME"
cd "$INSTALL_DIR"

if [ -d "$HOME/piKISS" ]; then
	cd "$HOME/piKISS" && ./piKiss.sh
	exit
fi

if [[ ! $(cat /proc/cpuinfo | grep 'BCM2708\|BCM2709\|BCM2835') ]]; then
	echo "Sorry. PiKISS is only for Raspberry Pi boards."
    exit
fi

echo -e "\nPiKISS\n======\nInstalling at $HOME/piKISS. Please wait...\n"
sudo apt install -y dialog
git clone https://github.com/jmcerrejon/PiKISS.git piKiss && cd "$_"
./piKiss.sh
