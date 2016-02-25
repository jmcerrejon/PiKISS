#!/bin/bash
#
# Description : GameMaker pack games installation
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (25/Feb/16)
#
#
clear

INSTALL_DIR="/home/$USER/games/gmaker/"
URL_FILE="https://www.yoyogames.com/download/pi/tntbf https://www.yoyogames.com/download/pi/crate https://www.yoyogames.com/download/pi/castilla"

changeInstallDir(){
    echo "Enter new full path:"
    read INSTALL_DIR
    echo "New path: $INSTALL_DIR"
}

install(){
    mkdir -p $INSTALL_DIR && cd $_
    wget $URL_FILE && tar xzvf castilla && tar xzvf tntbf && tar xzvf crate && rm castilla crate tntbf
    echo "Done!. To play go to install path, cd into game and run with ./SuperCrateBox, ./MalditaCastilla or ./TheyNeedToBeFed"
    read -p "Press [Enter] to continue..."
    exit
}

echo "Install GameMaker pack games"
echo "============================"
echo -e "More Info: http://yoyogames.com/pi\n\nInstall path: $INSTALL_DIR"
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
