#!/bin/bash
#
# Description : Picodrive
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1 (14/Nov/18)
# Compatible  : Raspberry Pi 1, 2 & 3 (tested)
#
# HELP        : https://www.raspberrypi.org/forums/viewtopic.php?f=78&t=105811
#
clear

INSTALL_DIR="$HOME/games"
URL_FILE="http://misapuntesde.com/res/picodrive192.tar.gz"
GAME_URL="http://repixel8.com/downloads/games/doroppu.bin"

if  which $INSTALL_DIR/picodrive/PicoDrive_rpi2 >/dev/null ; then
    read -p "Warning!: Picodrive already installed. Press [ENTER] to exit..."
    exit
fi

playgame()
{
    if [[ -f $INSTALL_DIR/picodrive/doroppu.bin ]]; then
        read -p "Do you want to play Doroppu now? [y/n] " option
        case "$option" in
            y*) cd $INSTALL_DIR/picodrive/ && ./PicoDrive_rpi2 doroppu.bin ;;
        esac
    fi
}

install()
{
    mkdir -p $INSTALL_DIR && cd $_
    wget $URL_FILE && tar jxf picodrive-rpi-chips-0_1.bz2 && rm picodrive-rpi-chips-0_1.bz2
    cd picodrive
    wget $GAME_URL

    echo "Done!. To play go to install path, copy any ROM file to $INSTALL_DIR/picodrive and type: ./PicoDrive_rpi1 or ./PicoDrive_rpi2 <game name>"
    playgame
    read -p "Press [Enter] to continue..."
    exit
}

echo -e "Picodrive v1.91 with OpenGLES\n=============================\n\n· Thanks to Chips, NotaZ & Repixel8.\n· More Info: https://www.raspberrypi.org/forums/viewtopic.php?f=78&t=105811\n· Add game doroppu to play\n\nInstall path: $INSTALL_DIR/picodrive"
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
