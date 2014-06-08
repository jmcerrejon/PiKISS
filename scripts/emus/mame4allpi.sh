#!/bin/bash
#
# Description : MAME4ALL for Pi by Squid
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (15/May/14)
#
clear

INSTALL_DIR="/home/$USER/games/mame4allpi/"
URL_FILE="http://mame4all-pi.googlecode.com/git/mame4all_pi.zip"

validate_url(){
    if [[ `wget -S --spider $1 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then echo "true"; fi
}

changeInstallDir(){
    echo "Enter new full path:"
    read INSTALL_DIR
    echo "New path: $INSTALL_DIR"
}

install(){
    if [[ $(validate_url $URL_FILE) != "true" ]] ; then
        echo "Sorry, the emulator is not available here: $URL_FILE. Visit the website to download it manually."
        exit
    else 
        mkdir -p $INSTALL_DIR && cd $_
        wget -qO- -O tmp.zip $URL_FILE && unzip -o tmp.zip && rm tmp.zip
        chmod 777 ./mame.cfg ./samples ./artwork ./cfg ./inp ./snap ./hi ./roms ./nvram ./skins ./memcard ./frontend ./folders
        echo "Done!. To play go to install path, copy any rom to /roms directory and type: ./mame <rom name>"
    fi
    read -p "Press [Enter] to continue..."
    exit
}

echo -e "Install MAME4ALL for Pi (latest)\n================================\n\nMore Info: https://code.google.com/p/mame4all-pi/\n\nInstall path: $INSTALL_DIR"
while true; do
    echo " "
    read -p "Is it right? [y/n] " yn
    case $yn in
    [Yy]* ) echo "Installing, please wait..." && install;;
    [Nn]* ) changeInstallDir;;
    [Ee]* ) exit;;
    * ) echo "Please answer (y)es, (n)o or (e)xit.";;
    esac
done
