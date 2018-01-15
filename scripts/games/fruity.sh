#!/bin/bash
#
# Description : Fruit'Y
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (14/Jan/18)
# Compatible  : Raspberry Pi 1, 2 & 3 (tested)
#
clear

INSTALL_DIR="/home/$USER/games/fruity_rpi/"
URL_FILE="http://www.retroguru.com/fruity/fruity-v.latest-raspberrypi.zip"

if  which $INSTALL_DIR/fruity_rpi >/dev/null ; then
    read -p "Warning!: Fruit'Y already installed. Press [ENTER] to exit..."
    exit
fi

validate_url(){
    if [[ `wget -S --spider $1 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then echo "true"; fi
}

generateIcon(){
    if [[ ! -e ~/.local/share/applications/Fruity.desktop ]]; then
cat << EOF > ~/.local/share/applications/Fruity.desktop
[Desktop Entry]
Name=Fruity
Exec=/home/pi/games/fruity_rpi/fruity_rpi
Icon=terminal
Type=Application
Comment=Playing with edibles is heavily inspired by the Kaiko classic Gem'X
Categories=Game;ActionGame;
Path=/home/pi/games/fruity_rpi/
EOF
    fi
}

install(){
    if [[ $(validate_url $URL_FILE) != "true" ]] ; then
        read -p "Sorry, the game is not available here: $URL_FILE. Visit the website to download it manually."
        exit
    else
        mkdir -p $INSTALL_DIR && cd $INSTALL_DIR
        wget -O /tmp/temp.zip $URL_FILE && unzip -o /tmp/temp.zip -d /home/$USER/games/ && rm /tmp/temp.zip
        chmod +x fruity_rpi
        echo "Generating icon..."
        generateIcon
        echo -e "Done!. To play, on Desktop go to Menu > Games or via terminal, go to $INSTALL_DIR and type: ./fruity_rpi\n\nEnjoy!"
    fi
    read -p "Press [Enter] to continue..."
    exit
}

echo "Install Fruit'Y (Raspberry Pi version)"
echo "======================================"
echo -e "More Info: http://www.retroguru.com/fruity/\n\nInstall path: $INSTALL_DIR"
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
