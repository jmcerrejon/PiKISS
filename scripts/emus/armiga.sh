#!/bin/bash
#
# Description : UAE4ARMIGA4PI (Amiga emu)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.8 (1/Jul/14)
#
# HELP        · http://fdarcel.free.fr/ | http://www.raspberrypi.org/forums/viewtopic.php?p=491284#p491284
#
clear

INSTALL_DIR="/home/$USER/games"
URL_FILE="http://www.armigaproject.com/pi/uae4armiga4pi.tar.gz"
KICK_FILE="http://misapuntesde.com/res/Amiga_roms.zip"

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
        sudo apt-get install -y libsdl1.2debian libsdl-mixer1.2 libsdl-ttf2.0-0
        mkdir -p $INSTALL_DIR && cd $_
        wget -qO- -O tmp.tar.gz $URL_FILE && tar xzf tmp.tar.gz && rm tmp.tar.gz
        cd uae4armiga4pi/
        wget $KICK_FILE && unzip Amiga_roms.zip && mv kick13.rom kick.rom && rm Amiga_roms.zip
        cd ADFs/
        wget http://www.emuparadise.me/GameBase%20Amiga/Games/T/Turrican.zip && unzip -o Turrican.zip && rm Turrican.zip
        wget -O $INSTALL_DIR/uae4armiga4pi/COVERs/Turrican.adf.jpg http://files.xboxic.com/turrican2.jpg
        echo "Done!. To play you need to uncomment framebuffer display from /boot/config.txt and then, go to install path and type: ./uae4armiga4pi"
    fi
    read -p "Press [Enter] to continue..."
    exit
}

echo -e "UAE4ARMIGA4PI (Amiga emu)\n=========================\n\nMore Info: http://www.armigaproject.com/pi/pi.html\n\nInstall path: $INSTALL_DIR/uae4armiga4pi"
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
