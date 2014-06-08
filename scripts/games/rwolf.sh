#!/bin/bash
#
# Description : castle Wolfenstein
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.8 (08/Jun/14)
#
clear

INSTALL_DIR="/home/$USER/games"
URL_FILE="https://github.com/hexameron/RaspberryPiRecipes/archive/master.zip"
PAK_FILE="ftp://ftp.gr.freebsd.org/pub/vendors/idgames/idstuff/wolf/linux/wolfspdemo-linux-1.1b.x86.run"

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
        wget -qO- -O tmp.zip $URL_FILE && unzip -o tmp.zip  && rm tmp.zip
        wget -O /tmp/wolfspdemo-linux-1.1b.x86.run $PAK_FILE
        tail -n +175 /tmp/wolfspdemo-linux-1.1b.x86.run | tar -xz $INSTALL_DIR/RaspberryPiRecipes-master/built/RTCW/main/pak0.pk3
        rm /tmp/wolfspdemo-linux-1.1b.x86.run
        echo "Done!. You may need 160GB assigned to GPU. To play go to install path and type: /built/RTCW/wolfsp.arm"
    fi
    read -p "Press [Enter] to continue..."
    exit
}

echo -e "Return to Castle Wolfenstein (Demo)\n===================================\n\nMore Info: http://www.raspberrypi.org/forums/viewtopic.php?f=78&t=14975\n\nInstall path: $INSTALL_DIR/RaspberryPiRecipes-master"
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
