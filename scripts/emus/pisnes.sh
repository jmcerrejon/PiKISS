#!/bin/bash
#
# Description : PiSNES for Raspberry Pi by Squid
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9.3 (5/Apr/15)
# Compatible  : Raspberry Pi 1 (Doesn't work) & 2 (tested. OK.)
#
clear

. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games/pisnes/"
URL_FILE="http://sourceforge.net/projects/pisnes/files/latest/download?source=files"
GAME_URL="http://www.dropbox.com/s/b6tl84p3a17w5ab/UwolQuestForMoney.sfc?dl=0"

playgame()
{
    read -p "Do you want to play Uwol Quest For Money now? [y/n] " option
    case "$option" in
        y*) $INSTALL_DIR/snes9x $INSTALL_DIR/roms/uwol.sfc ;;
    esac
}

changeInstallDir()
{
    echo "Enter new full path:"
    read INSTALL_DIR
    echo "New path: $INSTALL_DIR"
}

install()
{
    mkdir -p $INSTALL_DIR && cd $_
    wget -qO- -O tmp.zip $URL_FILE && unzip -o tmp.zip && rm tmp.zip
    chmod 777 ./snes9x ./snes9x.cfg ./roms ./skins
    echo -e "\nInstalling game Uwol Quest For Money (uwol.sfc) on $INSTALL_DIR\n\n" && wget -q -O $INSTALL_DIR/roms/uwol.sfc  $GAME_URL
    echo -e "Done!. To play go to install path, copy any rom to /roms directory and type: ./snes9x <rom name>\nFor example, ./snes9x roms/uwol.sfc"
    playgame
    read -p "Press [Enter] to continue..."
    exit
}

echo -e "Install PiSNES (Version 1.39)\n=============================\nMore Info: http://sourceforge.net/projects/pisnes\n\nInstall path: $INSTALL_DIR"
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
