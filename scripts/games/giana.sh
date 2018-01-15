#!/bin/bash
#
# Description : Giana's Return
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (07/Sep/16)
# Compatible  : Raspberry Pi 1, 2 & 3 (tested)
#
clear

INSTALL_DIR="/home/$USER/games/giana/"
URL_FILE="http://www.retroguru.com/gianas-return/gianas-return-v.latest-raspberrypi.zip"

if  which $INSTALL_DIR/xump_rpi >/dev/null ; then
    read -p "Warning!: Giana already installed. Press [ENTER] to exit..."
    exit
fi

validate_url(){
    if [[ `wget -S --spider $1 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then echo "true"; fi
}

generateIcon(){
    if [[ ! -e ~/.local/share/applications/Giana.desktop ]]; then
cat << EOF > ~/.local/share/applications/Giana.desktop
[Desktop Entry]
Name=Giana Return
Exec=/home/pi/games/giana/giana_rpi
Icon=terminal
Type=Application
Comment=Evil Swampy and his followers have stolen the magic ruby, which made it once possible for Giana and Maria to return from their dream
Categories=Game;ActionGame;
Path=/home/pi/games/giana/
EOF
    fi
}

install(){
    if [[ $(validate_url $URL_FILE) != "true" ]] ; then
        read -p "Sorry, the game is not available here: $URL_FILE. Visit the website to download it manually."
        exit
    else
        mkdir -p $INSTALL_DIR && cd $INSTALL_DIR
        wget -O /tmp/temp.zip $URL_FILE && unzip -o /tmp/temp.zip -d $INSTALL_DIR && rm /tmp/temp.zip
        chmod +x giana_rpi
        echo "Generating icon..."
        generateIcon
        echo -e "Done!. To play, on Desktop go to Menu > Games or via terminal, go to $INSTALL_DIR and type: ./giana_rpi\n\nEnjoy!"
    fi
    read -p "Press [Enter] to continue..."
    exit
}

echo "Install Giana's Return (Raspberry Pi version)"
echo "============================================="
echo -e "More Info: http://www.gianas-return.de/\n\nInstall path: $INSTALL_DIR"
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
