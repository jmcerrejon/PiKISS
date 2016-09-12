#!/bin/bash
#
# Description : Samba config
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (9/May/2015)
#
# HELP		  : http://www.makeuseof.com/tag/adblock-everywhere-raspberry-pi-hole-way/
#
clear

echo -e "Turn Raspberry Pi into a network-wide ad blocker\n\nInstalling, please wait..."

curl -s https://raw.githubusercontent.com/jacobsalmela/pi-hole/master/automated%20install/basic-install.sh | bash

read -p 'Press [ENTER] to continue...'
