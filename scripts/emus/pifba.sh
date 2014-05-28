#!/bin/bash
#
# Description : Final Burn Alpha 2x for Raspberry Pi by Squid
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9 (7/May/14)
#
clear

INSTALL_DIR="/home/$USER/games/pifba/"
URL_FILE="http://pifba.googlecode.com/git/piFBA.zip"

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
        chmod 777 ./fba2x ./fbacapex ./capex.cfg ./fba2x.cfg ./zipname.fba ./rominfo.fba ./FBACache_windows.zip ./fba_029671_clrmame_dat.zip ./roms ./skin ./preview ./preview/*
        echo "Done!. To play go to install path, copy any rom to /roms directory and type: ./fbacapex to show the front-end"
    fi
    read -p "Press [Enter] to continue..."
    exit
}

echo "Final Burn Alpha 2x for Raspberry Pi"
echo "===================================="
echo -e "More Info: https://code.google.com/p/pifba/\n\nInstall path: $INSTALL_DIR"
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