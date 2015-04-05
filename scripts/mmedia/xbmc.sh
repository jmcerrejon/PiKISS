#!/bin/bash
#
# Description : Install XBMC - Kodi
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9.1 (5/Apr/15)
# Compatible  : Raspberry Pi 1 & 2 (tested)
#
# HELP        · http://michael.gorven.za.net/raspberrypi/xbmc
#
# TODO	      [ ] Ask user if want to start Kodi from boot.
#	          [V] Get the latest version
#
clear

echo -e "KODI Install (14.1)\n=====================\n· Install 133MB aprox."
echo "deb http://archive.mene.za.net/raspbian wheezy contrib" | sudo tee -a /etc/apt/sources.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key 5243CDED
sudo apt-get update
sudo apt-get install -y xbmc

sudo usermod -a -G "audio,video,input,dialout,plugdev,tty" $USER
sudo addgroup --system input

read -p "Done!. Type kodi to run. Press [Enter] to continue..."
