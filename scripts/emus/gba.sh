#!/bin/bash
#
# Description : Gameboy Advance emulator thanks to DPR
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (26/Jun/14)
#
# HELP        · http://www.raspberrypi.org/forums/viewtopic.php?f=78&t=37433
#
clear

INSTALL_DIR="/home/$USER/games"
URL_FILE="https://www.dropbox.com/s/u3wjlbdp4kav5kg/gpsp.tar.gz"

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
        #sudo apt-get install -y libsdl1.2debian libsdl-mixer1.2 libsdl-ttf2.0-0
        mkdir -p $INSTALL_DIR && cd $_
        wget -qO- -O tmp.tar.gz $URL_FILE && tar xzf tmp.tar.gz && rm tmp.tar.gz
        cd gpsp/
        wget -O watman.zip 'http://computeremuzone.com/contador.php?f_ad=watman_gba.zip&dd=consolas/gba&n_ar=Watman%20(Batman%20remake)%20(GBA)'
        echo "Done!. To play, go to install path and type: ./gpsp"
    fi
    read -p "Press [Enter] to continue..."
    exit
}

echo -e "Gameboy Advance Emulator (gpsp)\n===============================\n\n· More Info: http://www.raspberrypi.org/forums/viewtopic.php?f=78&t=37433\n· Batman by OCEAN remake included. More info: http://computeremuzone.com/ficha.php?id=593&l=en\n· Works with compressed roms (.zip)\n\nInstall path: $INSTALL_DIR/gpsp"
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
