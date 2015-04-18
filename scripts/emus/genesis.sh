#!/bin/bash
#
# Description : Picodrive
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (18/Apr/15)
# Compatible  : Raspberry Pi 1 & 2 (tested)
#
# HELP        : https://www.raspberrypi.org/forums/viewtopic.php?f=78&t=105811
#
clear

INSTALL_DIR="$HOME/games/"
URL_FILE="http://fdarcel.free.fr/picodrive-rpi-chips-0_1.bz2"
GAME_URL="http://repixel8.com/downloads/games/doroppu.bin"

playgame()
{
    if [[ -f $INSTALL_DIR/picodrive/doroppu.bin ]]; then
        read -p "Do you want to play Doroppu now? [y/n] " option
        case "$option" in
            y*) cd $INSTALL_DIR/picodrive/ && ./PicoDrive_rpi1 doroppu.bin ;;
        esac
    fi
}

changeInstallDir()
{
    echo "Enter new full path:"
    read INSTALL_DIR
    echo "New path: $INSTALL_DIR"
}

install()
{
    if [[ ! -f $INSTALL_DIR/picodrive/PicoDrive_rpi1 ]]; then
        mkdir -p $INSTALL_DIR && cd $_
        wget $URL_FILE && tar jxf picodrive-rpi-chips-0_1.bz2 && rm picodrive-rpi-chips-0_1.bz2
        cd picodrive
        # Download Rom
        wget $GAME_URL
    fi
    echo "Done!. To play go to install path, copy any .tap file to directory and type: ./PicoDrive_rpi1 or ./PicoDrive_rpi2 <game name>"
    playgame
    read -p "Press [Enter] to continue..."
    exit
}

echo -e "Picodrive v1.91 with OpenGLES\n=============================\n\n· Thanks to Chips, NotaZ & Repixel8.\n· More Info: https://www.raspberrypi.org/forums/viewtopic.php?f=78&t=105811\n· Add game doroppu to play\n\nInstall path: $INSTALL_DIR/picodrive"
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
