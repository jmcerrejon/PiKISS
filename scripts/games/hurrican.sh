#!/bin/bash
#
# Description : Hurrican created by Poke53280
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.3 (03/Jan/21)
# Compatible  : Raspberry Pi 1-4 (tested)
#
# Note		  : Compiled thanks to the valuable help from Russ Le Blang
#

. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly BINARY_PATH="https://misapuntesde.com/rpi_share/hurrican_rpi.tar.gz"

runme() {
    echo
    if [ ! -f "$INSTALL_DIR"/hurrican/hurrican ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/hurrican && ./hurrican
    clear
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/hurrican ~/.local/share/applications/hurrican.desktop
}

uninstall() {
    read -p "Do you want to uninstall Hurrican (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/hurrican ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/hurrican ]]; then
    echo -e "Hurrican already installed.\n"
    uninstall
    exit 1
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/hurrican.desktop ]]; then
        cat <<EOF >~/.local/share/applications/hurrican.desktop
[Desktop Entry]
Name=Hurrican
Exec=${PWD}/hurrican/hurrican
Icon=${PWD}/hurrican/Hurrican.ico
Path=${PWD}/hurrican/
Type=Application
Comment=Freeware jump and shoot game created by Poke53280 that is based on the Turrican game series
Categories=Game;ActionGame;
EOF
    fi
}

install() {
    echo -e "\nInstalling hurrican, please wait..."
    download_and_extract "$BINARY_PATH" "$INSTALL_DIR"
    generate_icon
    echo -e "\nType in a terminal $INSTALL_DIR/hurrican/hurrican or go to Menu > Games > Hurrican."
    runme
}

install_script_message
install
