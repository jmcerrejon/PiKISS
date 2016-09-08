#!/bin/bash
#
# Description : Install XBMC - Kodi
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9.2 (8/Sep/16)
# Compatible  : Raspberry Pi 1, 2 & 3 (tested)
#
# HELP        · https://www.raspberrypi.org/forums/viewtopic.php?p=832735#p832735
#
# TODO	      [ ] Ask user if want to start Kodi from boot.
#
clear

echo -e "KODI Install (16.1)\n=====================\n"

echo "deb http://pipplware.pplware.pt/pipplware/dists/jessie/main/binary /" | sudo tee -a /etc/apt/sources.list
wget -O - http://pipplware.pplware.pt/pipplware/key.asc | sudo apt-key add -

sudo apt-get update
sudo apt-get install -y xbmc

sudo usermod -a -G "audio,video,input,dialout,plugdev,tty" $USER
sudo addgroup --system input

read -p "Done!. Type kodi to run. Press [Enter] to continue..."
