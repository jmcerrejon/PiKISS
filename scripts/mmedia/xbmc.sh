#!/bin/bash
#
# Description : Install XBMC
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.8 (15/May/14)
#
# TODO	      · Ask user if want to start XBMC from boot.
#	      · Get the latest version
#
clear

echo -e "XBMC Install (12.3)\n=====================\n· Install 127MB aprox."
echo "deb http://archive.mene.za.net/raspbian wheezy contrib" | sudo tee -a /etc/apt/sources.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key 5243CDED
sudo apt-get update
sudo apt-get install -y xbmc
read -p "Done!. Type xbmc to run. Press [Enter] to continue..."
