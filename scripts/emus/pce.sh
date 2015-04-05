#!/bin/bash
#
# Description : PCE-CD emulation by Vanfanel
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1 (5/Apr/15)
# Compatible  : Raspberry Pi 1 & 2 (tested)
#
# HELP        · http://www.raspberrypi.org/forums/viewtopic.php?f=78&t=80357
#
clear

INSTALL_DIR="$HOME/games"
URL_FILE="https://www.dropbox.com/s/vzn3932ugh0q4rx/pce_rpi.zip"
ROM_URL='http://aetherbyte.com/files/Aetherbyte_Reflectron.zip'

playgame()
{
    if [[ -f $HOME/games/pce/Aetherbyte_Reflectron.zip ]]; then
        read -p "Do you want to play Reflectron now? [y/n] " option
        case "$option" in
            y*) cd $HOME/games/pce && ./pce Aetherbyte_Reflectron.zip ;;
        esac
    fi
}

install()
{
    #sudo apt-get install -y libsdl1.2debian libsdl-mixer1.2 libsdl-ttf2.0-0
    if [[ ! -e $HOME/games/pce ]]; then
        mkdir -p $INSTALL_DIR && cd $_
        wget -qO- -O tmp.zip $URL_FILE && unzip tmp.zip && rm tmp.zip
        cd pce/
        wget $ROM_URL
    fi
    echo "Done!. To play, go to install path and type: ./pce Aetherbyte_Reflectron.zip"
    playgame
    clear
    read -p "Press [Enter] to continue..."
    exit
}

echo -e "PCE-CD emulation by Vanfanel\n============================\n\n· More Info: http://www.raspberrypi.org/forums/viewtopic.php?f=78&t=80357\n· + Game Reflectron by Aetherbyte\n· Works with compressed roms (.zip)\n· Install path: $INSTALL_DIR/pce\n\nInstalling, please wait..."
install
