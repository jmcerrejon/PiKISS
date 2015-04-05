#!/bin/bash
#
# Description : Portable ZX-Spectrum emulator by JFroco
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.3 (5/Apr/15)
#
clear

INSTALL_DIR="/home/$USER/games/"
URL_FILE="https://dl.dropboxusercontent.com/u/4281970/pi/usp_0.0.59_jfroco.zip"

validate_url()
{
    if [[ `wget -S --spider $1 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then echo "true"; fi
}

playgame()
{
    if [[ -f $INSTALL_DIR/usp_0.0.59_jfroco/ninjajar.tap ]]; then
        read -p "Do you want to play NinJaJar now? [y/n] " option
        case "$option" in
            y*) cd $INSTALL_DIR/usp_0.0.59_jfroco/ && ./unreal_speccy_portable ninjajar.tap ;;
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
    if [[ ! -f $INSTALL_DIR/usp_0.0.59_jfroco/unreal_speccy_portable ]]; then
        mkdir -p $INSTALL_DIR && cd $_
        wget -qO- -O tmp.zip $URL_FILE && unzip -o tmp.zip && rm tmp.zip
        cd us*
        chmod +x unreal_speccy_portable
        wget -O $INSTALL_DIR/usp_0.0.59_jfroco/ninjajar.tap http://www.mojontwins.com/juegos/mojon-twins--ninjajar-eng-v1.1.tap
        
    fi
    echo "Done!. To play go to install path, copy any .tap file to directory and type: ./unreal_speccy_portable <game name>"
    playgame
    read -p "Press [Enter] to continue..."
    exit
}

echo -e "Portable ZX-Spectrum emulator (unrealspeccyp ver. 0.59)\n=======================================================\n\n· More Info: https://bitbucket.org/djdron/unrealspeccyp\n· Add Ninjajar\n\nInstall path: $INSTALL_DIR/usp_0.0.59_jfroco"
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
