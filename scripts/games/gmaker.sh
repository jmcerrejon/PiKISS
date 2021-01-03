#!/bin/bash
#
# Description : GameMaker pack games installation
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.2 (03/Jan/21)
# Compatible  : Raspberry Pi 1,2 & 3 (tested)
#
#
. ./scripts/helper.sh || . ../helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly URL_FILE="https://www.yoyogames.com/download/pi/tntbf https://www.yoyogames.com/download/pi/crate https://www.yoyogames.com/download/pi/castilla"

generate_icon() {
    echo -e "\nGenerating desktop icons"
    # Maldita castilla
    if [[ ! -e ~/.local/share/applications/castilla.desktop ]]; then
        cat <<EOF >~/.local/share/applications/castilla.desktop
[Desktop Entry]
Name=Maldita Castilla
Exec=${PWD}/MalditaCastilla/MalditaCastilla
Icon=terminal
Type=Application
Comment=Maldita Castilla (Cursed/damn Castile) is an action arcade game full of myths from Spain and the rest of Europe
Categories=Game;ActionGame;
EOF
    fi
    # Super Crate Box
    if [[ ! -e ~/.local/share/applications/crate.desktop ]]; then
        cat <<EOF >~/.local/share/applications/crate.desktop
[Desktop Entry]
Name=Super Crate Box
Exec=${PWD}/SuperCrateBox/SuperCrateBox
Icon=terminal
Type=Application
Comment=Prepare for an arcade delight with tight controls, refreshing game mechanics
Categories=Game;ActionGame;
EOF
    fi
    # They Need To BeFed
    if [[ ! -e ~/.local/share/applications/need.desktop ]]; then
        cat <<EOF >~/.local/share/applications/need.desktop
[Desktop Entry]
Name=They Need To BeFed
Exec=${PWD}/TheyNeedToBeFed/TheyNeedToBeFed
Icon=terminal
Type=Application
Comment=Run and jump through 11 crazy worlds to feed the monsters in this 360° gravity platformer
Categories=Game;ActionGame;
EOF
    fi
}

install() {
    echo -e "\nInstalling, please wait..."
    mkdir -p "$INSTALL_DIR/gmaker" && cd "$_" || exit 1
    wget "$URL_FILE" && tar xzvf castilla && tar xzvf tntbf && tar xzvf crate && rm castilla crate tntbf
    echo -e "\nModifying GPU=256 on /boot/config.txt"
    sudo mount -o remount,rw /boot
    sudo cp /boot/config.txt{,.bak}
    set_GPU_memory 256
    generate_icon
    echo "Done!. To play, Open the Menu > Games from Desktop or go to install path, cd into game and run with ./SuperCrateBox, ./MalditaCastilla or ./TheyNeedToBeFed"
    read -p "Press [Enter] to continue..."
    exit
}

install_script_message
echo "
Install GameMaker pack games
============================

 · Install path: $INSTALL_DIR/gmaker

"

read -p "Installing..."

install
