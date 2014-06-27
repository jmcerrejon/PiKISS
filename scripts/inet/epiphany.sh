#! /bin/bash
#
# Description : Install this browser called Epiphany
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (26/Jun/14)
#
clear

echo -e "\nEpiphany\n========\n\nInstalling, please wait..."

echo "deb http://raspberrypi.collabora.com wheezy web" | sudo tee -a /etc/apt/sources.list

sudo apt-get update && sudo apt-get install -y epiphany-browser

read -p "Done!. Start the browser from the applications menu Internet > Epiphany Web Browser"