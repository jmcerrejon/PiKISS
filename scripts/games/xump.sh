#!/bin/bash
#
# Description : Xump
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (07/Sep/16)
# Compatible  : Raspberry Pi 1, 2 & 3 (tested)
#
clear

INSTALL_DIR="/home/$USER/games/xump/"
URL_FILE="http://www.retroguru.com/xump/xump-v.latest-raspberrypi.zip"

if  which $INSTALL_DIR/xump_rpi >/dev/null ; then
    read -p "Warning!: Xump already installed. Press [ENTER] to exit..."
    exit
fi

validate_url(){
    if [[ `wget -S --spider $1 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then echo "true"; fi
}

generateIcon(){
    if [[ ! -e ~/.local/share/applications/Xump.desktop ]]; then
cat << EOF > ~/.local/share/applications/Xump.desktop
[Desktop Entry]
Name=Xump
Exec=/home/pi/games/xump/xump_rpi
Icon=terminal
Type=Application
Comment=Xump - The Final Run is a simple multi-platform puzzler by Retroguru
Categories=Game;ActionGame;
Path=/home/pi/games/xump/
EOF
    fi
}

install(){
    if [[ $(validate_url $URL_FILE) != "true" ]] ; then
        read -p "Sorry, the game is not available here: $URL_FILE. Visit the website to download it manually."
        exit
    else
        mkdir -p $INSTALL_DIR && cd $_
        wget -O /tmp/xump.zip $URL_FILE && unzip -o /tmp/xump.zip -d $INSTALL_DIR && rm /tmp/xump.zip
        chmod +x xump_rpi
        echo "Generating icon..."
        generateIcon
        echo -e "Done!. To play, on Desktop go to Menu > Games or via terminal, go to $INSTALL_DIR and type: ./xump_rpi\n\nEnjoy!"
    fi
    read -p "Press [Enter] to continue..."
    exit
}

echo "Install Xump(Raspberry Pi version)"
echo "=================================="
echo -e "More Info: http://www.retroguru.com/xump/\n\nInstall path: $INSTALL_DIR"
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
