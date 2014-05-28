#!/bin/bash
#
# Description : Sqrxz4 game installation 
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9 (7/May/14)
#
# TODO        · Check dependencies to: SDL, SDL_Mixer, libmodplug and zlib
#
clear

INSTALL_DIR="/home/$USER/games/sqrxz4/"
URL_FILE="http://www.retroguru.com/sqrxz4/sqrxz4-v.latest-raspberrypi.zip"

# validate_url thanks to https://gist.github.com/hrwgc/7455343
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
        echo "Sorry, the game is not available here: $URL_FILE. Visit the website to download it manually."
        exit
    else 
        mkdir -p $INSTALL_DIR && cd $_
        wget -O /tmp/sqrxz4.zip $URL_FILE && unzip -o /tmp/sqrxz4.zip -d $INSTALL_DIR && rm /tmp/sqrxz4.zip
        echo "Done!. To play go to install path and type: ./sqrxz4_rpi"
    fi
    read -p "Press [Enter] to continue..."
    exit
}

echo "Install Sqrxz 4 (Raspberry Pi version)"
echo "======================================"
echo -e "More Info: http://www.sqrxz.de/sqrxz-4/\n\nInstall path: $INSTALL_DIR"
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