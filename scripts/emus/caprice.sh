#!/bin/bash
#
# Description : CapriceRPI2 for Raspberry Pi 2 (Amstrad)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (18/Apr/15)
# Compatible  : Raspberry Pi 2 (tested)
#
# HELP        : https://www.raspberrypi.org/forums/viewtopic.php?f=78&t=105811
#
clear

INSTALL_DIR="$HOME/games/"
URL_FILE="http://misapuntesde.com/res/CapriceRPI2-TEST_BUILD.tgz"
GAME_URL="http://www.amstradabandonware.com/mod/upload/ams_en/games_disk/brucelee.zip"

playgame()
{
    if [[ -f $INSTALL_DIR/caprice/disc/brucelee.dsk ]]; then
        read -p "Do you want to run caprice now? [y/n] " option
        case "$option" in
            y*) cd $INSTALL_DIR/caprice/ && ./capriceRPI2 ;;
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
    if [[ ! -f $INSTALL_DIR/caprice/capriceRPI2 ]]; then
        mkdir -p $INSTALL_DIR && cd $_
        wget $URL_FILE && tar xzvf CapriceRPI2-TEST_BUILD.tgz && rm CapriceRPI2-TEST_BUILD.tgz && mv RELEASE caprice
        cd caprice
        # Download Rom
        cd disc && wget $GAME_URL && unzip brucelee.zip && rm brucelee.zip && cd ..
    fi
    echo "Done!. Go to install path and type: ./capriceRPI2. F8 open the menu."
    playgame
    read -p "Press [Enter] to continue..."
    exit
}

echo -e "CapriceRPI2 for Raspberry Pi 2\n==============================\n\n· Thanks to KaosOverride.\n· F8: Menu\n· More Info: http://www.amstrad.es/forum/viewtopic.php?f=34&t=3878\n· Add game Bruce Lee (.dsk) to play\n\nInstall path: $INSTALL_DIR/picodrive"
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
