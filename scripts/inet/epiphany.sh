#! /bin/bash
#
# Description : Install this browser called Epiphany
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1 (2/Sep/14)
#
clear

echo -e "\nEpiphany\n========\n\nInstalling, please wait..."

sudo apt-get update && sudo apt-get install -y epiphany-browser

read -p "Done!. Start the browser from the applications menu Internet > Epiphany Web Browser"