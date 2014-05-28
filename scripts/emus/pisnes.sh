#!/bin/bash
#
# Description : PiSNES for Raspberry Pi by Squid
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9 (15/May/14)
#
clear

INSTALL_DIR="/home/$USER/games/pisnes/"
URL_FILE="http://pisnes.googlecode.com/git/pisnes.zip"

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
        chmod 777 ./snes9x ./snes9x.cfg ./roms ./skins
        echo "Done!. To play go to install path, copy any rom to /roms directory and type: ./snes9x <rom name>"
    fi
    read -p "Press [Enter] to continue..."
    exit
}

echo -e "Install PiSNES (Version 1.39)\n=============================\nMore Info: http://pisnes.googlecode.com\n\nInstall path: $INSTALL_DIR"
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
