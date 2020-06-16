#!/bin/bash
#
# Description : Compile 8086tiny is a free, open source PC XT-compatible emulator/virtual machine written in C
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (5/Apr/15)
# Compatible  : Raspberry Pi 1 & 2 (tested)
#
clear

. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games/"

changeInstallDir(){
    echo "Enter new full path:"
    read INSTALL_DIR
    echo "New path: $INSTALL_DIR"
}

install(){
    sudo apt-get install -y libsdl1.2-dev
    SDL_fix_Rpi
    mkdir -p $INSTALL_DIR && cd $_
    git clone https://github.com/adriancable/8086tiny.git
    cd 8086tiny/
    make
    echo -e "Done!. Type ./runme"
    read -p "Press [Enter] to continue..."
    exit
}

echo -e "Compile 8086tiny (latest)\n=========================\n· More Info: https://www.megalith.co.uk/8086tiny\n· Alley Cat game and FreeDOS included.\n· 43.6 MB of additional disk space will be used.\n\nInstall path: $INSTALL_DIR"
while true; do
    echo " "
    read -p "Is it right? [(Y)es/(N)o/(E)xit] " yn
    case $yn in
    [Yy]* ) echo "Installing, please wait..." && install;;
    [Nn]* ) changeInstallDir;;
    [Ee]* ) exit;;
    * ) echo "Please answer (y)es, (n)o or (e)xit.";;
    esac
done
