#!/bin/bash
#
# Description : rpix86 MS-DOS Emulator by Patrick Aalto
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (07/Sep/16)
#
# TODO        · syntax error near unexpected token '}' on comment code
clear

INSTALL_DIR="/home/$USER/games/rpix86/"
URL_FILE="http://rpix86.patrickaalto.com/rpix86.zip"

if  which $INSTALL_DIR/rpix86 >/dev/null ; then
    read -p "Warning!: rpix86 already installed. Press [ENTER] to exit..."
    exit
fi

validate_url(){
    if [[ `wget -S --spider $1 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then echo "true"; fi
}

extra(){
   local URL_FILE="http://misapuntesde.com/res/jill-of-the-jungle-the-complete-trilogy.zip"
   if [[ $(validate_url $URL_FILE) != "true" ]]; then
       echo "Sorry, the game is not available here: $URL_FILE."
   else
       echo "Installing the game..."
       mkdir -p $INSTALL_DIR/jill && cd $_
       wget -qO- -O tmp.zip $URL_FILE && unzip -o tmp.zip && rm tmp.zip
   fi
}

playgame()
{
    if [[ -f $INSTALL_DIR/rpix86 ]]; then
        read -p "Do you want to run MS-DOS emulator right now? [y/n] " option
        case "$option" in
            y*) cd $INSTALL_DIR && ./rpix86 ;;
        esac
    fi
}

install(){
    if [[ $(validate_url $URL_FILE) != "true" ]] ; then
        echo "Sorry, the emulator is not available here: $URL_FILE. Visit the website to download it manually."
        exit
    else
        mkdir -p $INSTALL_DIR && cd $_
        wget -qO- -O tmp.zip $URL_FILE && unzip -o tmp.zip && rm tmp.zip
        echo "Done!. To play go to install path and type: ./rpix86"
        read -p "EXTRA!: Do you want to download Jill of The Jungle Trilogy to play with rpix86? [y/n] " option
        case "$option" in
            y*) echo "Installing, please wait..." && extra;;
        esac
    fi
    playgame
    read -p "Press [Enter] to continue..."
    exit
}

echo -e "rpix86 MS-DOS Emulator (latest)\n===============================\nMore Info: http://rpix86.patrickaalto.com\n\nInstall path: $INSTALL_DIR"
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
