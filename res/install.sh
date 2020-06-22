#!/usr/bin/env bash
#
# Description : Easy install PiKISS
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (22/Jun/20)
# TODO		  : Check is a RPi, Check the OS is Debian based.
clear

if [ -d "$HOME/piKISS" ]; then
	cd "$HOME/piKISS" && ./piKiss.sh
fi

echo -e "\nPiKISS\n======\nInstalling at $HOME/piKISS. Please wait...\n"
sudo apt install -y dialog
git clone https://github.com/jmcerrejon/PiKISS.git piKiss && cd "$_"
./piKiss.sh
