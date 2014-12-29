#!/bin/bash
#
# Description : Install XBMC
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9.1 (29/Dec/14)
#
# HELP        · http://michael.gorven.za.net/raspberrypi/xbmc
#
# TODO	      [ ] Ask user if want to start XBMC from boot.
#	          [V] Get the latest version
#
clear

echo -e "XBMC Install (13.2)\n=====================\n· Install 131MB aprox."
echo "deb http://archive.mene.za.net/raspbian wheezy contrib" | sudo tee -a /etc/apt/sources.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key 5243CDED
sudo apt-get update
sudo apt-get install -y xbmc

sudo usermod -a -G "audio,video,input,dialout,plugdev,tty" $USER
sudo addgroup --system input

read -p "Done!. Type  xbmc-standalone to run. Press [Enter] to continue..."
