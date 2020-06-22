#!/usr/bin/env bash
#
# Description : Easy install PiKISS
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (22/Jun/20)
# TODO		  : Check is a RPi, Check Git is installed, Check the OS is Debian based.
clear

echo -e "\nPiKISS======\nInstalling at $HOME/piKISS. Please wait..."
git clone https://github.com/jmcerrejon/PiKISS.git piKiss && cd "$_"
./piKiss.sh
