#!/bin/bash
#
# Description : GameMaker pack games installation
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.1 (24/Aug/20)
# Compatible  : Raspberry Pi 1,2 & 3 (tested)
#
#
. ./scripts/helper.sh || . ../helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="/home/$USER/games/gmaker/"
URL_FILE="https://www.yoyogames.com/download/pi/tntbf https://www.yoyogames.com/download/pi/crate https://www.yoyogames.com/download/pi/castilla"

generateIcons() {
    # Maldita castilla
    if [[ ! -e ~/.local/share/applications/castilla.desktop ]]; then
cat << EOF > ~/.local/share/applications/castilla.desktop
[Desktop Entry]
Name=Maldita Castilla
Exec=/home/pi/games/gmaker/MalditaCastilla/MalditaCastilla
Icon=terminal
Type=Application
Comment=Maldita Castilla (Cursed/damn Castile) is an action arcade game full of myths from Spain and the rest of Europe
Categories=Game;ActionGame;
EOF
    fi
    # Super Crate Box
    if [[ ! -e ~/.local/share/applications/crate.desktop ]]; then
cat << EOF > ~/.local/share/applications/crate.desktop
[Desktop Entry]
Name=Super Crate Box
Exec=/home/pi/games/gmaker/SuperCrateBox/SuperCrateBox
Icon=terminal
Type=Application
Comment=Prepare for an arcade delight with tight controls, refreshing game mechanics
Categories=Game;ActionGame;
EOF
    fi
    # They Need To BeFed
    if [[ ! -e ~/.local/share/applications/need.desktop ]]; then
cat << EOF > ~/.local/share/applications/need.desktop
[Desktop Entry]
Name=They Need To BeFed
Exec=/home/pi/games/gmaker/TheyNeedToBeFed/TheyNeedToBeFed
Icon=terminal
Type=Application
Comment=Run and jump through 11 crazy worlds to feed the monsters in this 360° gravity platformer
Categories=Game;ActionGame;
EOF
    fi
}

install() {
    echo -e "\nInstalling, please wait..."
    mkdir -p "$INSTALL_DIR" && cd "$_"
    wget "$URL_FILE" && tar xzvf castilla && tar xzvf tntbf && tar xzvf crate && rm castilla crate tntbf
    echo -e "\nModifying GPU=256 on /boot/config.txt"
    sudo mount -o remount,rw /boot
    sudo cp /boot/config.txt{,.bak}
    set_GPU_memory 256
    echo -e "\nGenerating desktop icons"
    generateIcons
    echo "Done!. To play, Open the Menu > Games from Desktop or go to install path, cd into game and run with ./SuperCrateBox, ./MalditaCastilla or ./TheyNeedToBeFed"
    read -p "Press [Enter] to continue..."
    exit
}

echo "
Install GameMaker pack games
============================
 · Install path: $INSTALL_DIR

"
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
