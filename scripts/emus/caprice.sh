#!/bin/bash
#
# Description : Caprice32 for Raspberry Pi(Amstrad)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.2 (15/Jun/20)
# Compatible  : Raspberry Pi 2-4 (tested)
#
# HELP        : https://www.raspberrypi.org/forums/viewtopic.php?f=78&t=105811
#			  : For load disk, type cat and then run"game_name"
#
clear

INSTALL_DIR="$HOME/games"
URL_FILE="http://misapuntesde.com/res/caprice32_4-60.tar.gz"
GAME_URL="http://www.amstradabandonware.com/mod/upload/ams_en/games_disk/brucelee.zip"

if [[ -f $INSTALL_DIR/caprice/cap32 ]]; then
    read -p "Warning!: Caprice already installed. Press [ENTER] to exit..."
    exit
fi

playgame(){
    if [[ -f $INSTALL_DIR/caprice/disc/brucelee.dsk ]]; then
        read -p "Do you want to run caprice now? [y/n] " option
        case "$option" in
            y*) cd $INSTALL_DIR/caprice/ && ./cap32 ;;
        esac
    fi
}

install(){
    echo "Installing dependencies..."
    sudo apt install -y libts-0.0-0
    echo "Downloading packages..."
    mkdir -p $INSTALL_DIR/caprice && cd $_
    wget $URL_FILE && tar xzvf caprice32_4-60.tar.gz && rm caprice32_4-60.tar.gz
    cd disc && wget $GAME_URL && unzip brucelee.zip && rm brucelee.zip && cd ..

    echo "Done!. Go to install path and type: ./cap32. F1 open the menu."
    playgame
    read -p "Press [Enter] to continue..."
    exit
}

echo -e "Caprice32 for Raspberry Pi\n==========================\n\n· F1: Menu\n· More Info: https://github.com/ColinPitrat/caprice32\n· For load disk, type cat and then run\"game_name\"\n· Add game Bruce Lee (.dsk) to play\n\nInstall path: $INSTALL_DIR/caprice"
while true; do
    echo " "
    read -p "Proceed? [y/n] " yn
    case $yn in
    [Yy]* ) echo "Installing, please wait..." && install;;
    [Nn]* ) exit;;
    [Ee]* ) exit;;
    * ) echo "Please answer (y)es, (n)o or (e)xit.";;
    esac
done
