#!/bin/bash
#
# Description : Compile 8086tiny is a free, open source PC XT-compatible emulator/virtual machine written in C
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9 (27/Jun/14)
#
clear

INSTALL_DIR="/home/$USER/games/"
URL_FILE="http://rpix86.patrickaalto.com/rpix86.zip"

changeInstallDir(){
    echo "Enter new full path:"
    read INSTALL_DIR
    echo "New path: $INSTALL_DIR"
}

install(){
    sudo apt-get install -y libsdl1.2-dev
    mkdir -P $INSTALL_DIR
    git clone https://github.com/adriancable/8086tiny.git
    cd 8086tiny/
    make
    echo -e "Done!. Type ./runme"
    read -p "Press [Enter] to continue..."
    exit
}

echo -e "Compile 8086tiny (latest)\n===========================\n· More Info: http://www.megalith.co.uk/8086tiny\n· Alley Cat game and FreeDOS included.\n\nInstall path: $INSTALL_DIR"
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
