#!/bin/bash
#
# Description : Install MineCraft following a guide from http://www.raspberrypi-spy.co.uk
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1 (29/Dec/14)
#
clear

INSTALL_DIR="/home/$USER/games"
URL_FILE="https://s3.amazonaws.com/assets.minecraft.net/pi/minecraft-pi-0.1.1.tar.gz"

if [ $(sudo dpkg-query -l | grep minecraft-pi | wc -l) -eq 1 ];
then
    read -p "MineCraft already installed. Installation aborted. Have a nice day! :)"
    exit
fi

# validate_url thanks to https://gist.github.com/hrwgc/7455343
validate_url(){
    if [[ `wget -S --spider $1 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then echo "true"; fi
}

createDesktopIcon()
{
  FILE="\n[Desktop Entry]\n
Name=Minecraft Pi Edition\n
Comment=Launch Minecraft Pi Edition!\n
Exec=sh -c 'cd $INSTALL_DIR/mcpi && lxterminal -l -t Minecraft -e ./minecraft-pi'\n
Icon=$INSTALL_DIR/mcpi/minecraft.png\n
Terminal=false\n
Type=Application\n
Categories=Application;Games;\n
StartupNotify=true\n
"

  echo -e $FILE > $HOME/Desktop/minecraft.desktop
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
        wget -O $INSTALL_DIR/tmp.tar.gz $URL_FILE && tar -xzvf tmp.tar.gz && rm tmp.tar.gz

        if [[ ! -f $INSTALL_DIR"/mcpi/minecraft.png" ]] ; then
                wget -P $INSTALL_DIR"/mcpi" http://www.raspberrypi-spy.co.uk/wp-content/uploads/2013/10/minecraft.png
        fi
        createDesktopIcon
        lxpanelctl restart
    fi
    echo "Done!. To play go to install path and type from Desktop: ./minecraft-pi or click on the shortcut desktop icon."
    read -p "Press [Enter] to continue..."
    exit
}



echo "Install MineCraft (Raspberry Pi Ed)"
echo "==================================="
echo -e "More Info: http://www.raspberrypi-spy.co.uk/category/software/minecraft/\n\nInstall path: $INSTALL_DIR/mcpi"
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
