#!/bin/bash
#
# Description : Snes9X for Raspberry Pi by Squid
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.1 (17/Aug/20)
# Compatible  : Raspberry Pi 2-4
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }
clear

INSTALL_DIR="$HOME/games/snes9x"
URL_FILE="https://misapuntesde.com/res/snes9x_1-60.tar.gz"
GAME_URL="https://misapuntesde.com/rpi_share/UwolQuestForMoney.sfc"

playgame(){
    read -p "Do you want to play Uwol Quest For Money now? [y/n] " option
    case "$option" in
        y*) $INSTALL_DIR/snes9x $INSTALL_DIR/roms/uwol.sfc -fullscreen -maxaspect;;
    esac
}

changeInstallDir(){
    echo "Enter new full path:"
    read INSTALL_DIR
    echo "New path: $INSTALL_DIR"
}

install(){
    mkdir -p $HOME/games && cd $_
    wget -qO- -O tmp.tar.gz $URL_FILE && tar -xzvf tmp.tar.gz && rm tmp.tar.gz
    echo -e "\nInstalling game Uwol Quest For Money (uwol.sfc) on $INSTALL_DIR\n\n" && wget -q -O $INSTALL_DIR/roms/uwol.sfc  $GAME_URL
    echo -e "Done!. To play go to install path, copy any rom to /roms directory and type: ./snes9x <rom name>\nFor example, ./snes9x roms/uwol.sfc -fullscreen -maxaspect"
    playgame
    read -p "Press [Enter] to continue..."
    exit
}

echo -e "Install Snes9X (Version 1.60)\n=============================\n· More Info: https://github.com/snes9xgit/snes9x\n\n· Install free game Uwol Quest For Money thks to Mojon Twins.\n\n· Install path: $INSTALL_DIR"
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
