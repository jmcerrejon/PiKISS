#!/bin/bash
#
# Description : Final Burn Alpha 2x for Raspberry Pi with 4 players
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1 (29/Dec/14)
#
clear

INSTALL_DIR="/home/$USER/games/pifba/"
URL_FILE="https://github.com/digitalLumberjack/pifba/releases/download/0.3/pifba-0.3.zip"

changeInstallDir(){
    echo "Enter new full path:"
    read INSTALL_DIR
    echo "New path: $INSTALL_DIR"
}

install(){

    mkdir -p $INSTALL_DIR && cd $_
    wget -qO- -O tmp.zip $URL_FILE && unzip -o tmp.zip && rm tmp.zip
    #chmod 777 ./fba2x ./fbacapex ./capex.cfg ./fba2x.cfg ./zipname.fba ./rominfo.fba ./FBACache_windows.zip ./fba_029671_clrmame_dat.zip ./roms ./skin ./preview ./preview/*
    echo "Done!. To play go to install path, copy any rom to /roms directory and type: ./fba2x ./path/to/rom"

    read -p "Press [Enter] to continue..."
    exit
}

echo "Final Burn Alpha 2x for Raspberry Pi (4 players)"
echo "================================================"
echo -e "More Info: https://github.com/digitalLumberjack/pifba\n\nInstall path: $INSTALL_DIR"
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