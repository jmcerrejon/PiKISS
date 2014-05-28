#!/bin/bash
#
# Description : rpix86 MS-DOS Emulator by Patrick Aalto
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9 (15/May/14)
#
# TODO        · syntax error near unexpected token '}' on comment code
clear

INSTALL_DIR="/home/$USER/games/rpix86/"
URL_FILE="http://rpix86.patrickaalto.com/rpix86.zip"

validate_url(){
    if [[ `wget -S --spider $1 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then echo "true"; fi
}

#extra(){
#    local URL_FILE="http://misapuntesde.com/res/jill-of-the-jungle-the-complete-trilogy.zip"
#    if [[ $(validate_url $URL_FILE) != "true" ]] ; then
#        echo "Sorry, the game is not available here: $URL_FILE. Have a nice day!."
#        exit
#    else
#        mkdir -p $INSTALL_DIR && cd $_
#        wget -qO- -O tmp.zip $URL_FILE && unzip -o tmp.zip && rm tmp.zip
#        read -p "Done!. Press [Enter] to continue..."
#	exit
#}

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
        mkdir -p $INSTALL_DIR && cd $_
        wget -qO- -O tmp.zip $URL_FILE && unzip -o tmp.zip && rm tmp.zip
        echo "Done!. To play go to install path and type: ./rpix86"
#        while true; do
#            echo " "
#            read -p "EXTRA!: Do you want to download Jill of The Jungle Trilogy to play with rpix86? [y/n] " yn
#            case $yn in
#            [Yy]* ) echo "Installing, please wait..." && extra;;
#            [Nn]* ) exit;;
#            [Ee]* ) exit;;
#            * ) echo "Please answer (y)es, (n)o or (e)xit.";;
#            esac
#        done
    fi
    read -p "Press [Enter] to continue..."
    exit
}

echo -e "rpix86 MS-DOS Emulator (latest)\n===============================\nMore Info: http://rpix86.patrickaalto.com\n\nInstall path: $INSTALL_DIR"
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
