#!/bin/bash
#
# Description : Amiberry Amiga emulator
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.6.1 (09/Feb/25)
#
# shellcheck source=../helper.sh
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/Amiberry"
AMIBERRY_VERSION="v7.0.4"
ARCHITECTURE=$(getconf LONG_BIT)
PACKAGES=(libsdl2-image-2.0-0 libsdl2-ttf-2.0-0 flac libserialport0 libenet7)
RPI_MODEL=$(get_raspberry_pi_model_number)
FILE_NAME=
BINARY_URL="https://github.com/midwan/amiberry/releases/download/${AMIBERRY_VERSION}/amiberry-${AMIBERRY_VERSION}-debian-bookworm-arm${ARCHITECTURE}.zip"
GITHUB_PATH="https://github.com/midwan/amiberry.git"
KICK_FILE="https://misapuntesde.com/res/Amiga_roms.zip"
GAME="https://www.emuparadise.me/GameBase%20Amiga/Games/T/Turrican.zip"
ICON_URL="https://raw.githubusercontent.com/midwan/amiberry/master/data/amiberry.png"
INPUT=/tmp/amigamenu.$$
BINARY_EXEC_PATH="/usr/bin/amiberry"

runme() {
    if [[ ! -f $BINARY_EXEC_PATH ]]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run..."
    amiberry
    exit_message
}

uninstall() {
    read -p "Do you want to uninstall Amiberry (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo apt remove -y amiberry
        rm -rf "$INSTALL_DIR"
        if [[ -f $BINARY_EXEC_PATH ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -f $BINARY_EXEC_PATH ]]; then
    echo -e "Amiberry already installed.\n"
    uninstall
fi

post_install() {
    echo -e "\nPost install process. Just a moment..."
    downloadROM
    downloadKICK
    echo -e "\n\nDone!. You can play typing $INSTALL_DIR/amiberry/amiberry.sh or opening the Menu > Games > Amiberry.\n"
    runme
}

downloadKICK() {
    echo -e "\nCopying Rickstarts ROMs...\n"
    download_and_extract "$KICK_FILE" "$INSTALL_DIR/roms"
    mv "$INSTALL_DIR"/roms/kick13.rom "$INSTALL_DIR"/roms/kick.rom
}

downloadROM() {
    download_and_extract "$GAME" "$INSTALL_DIR/floppies"
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "/tmp"
    sudo dpkg -i /tmp/amiberry*.deb
    post_install
}

install_script_message
echo "
Amiberry for Raspberry Pi
=========================

 · Version ${AMIBERRY_VERSION}
 · More Info: https://github.com/midwan/amiberry
 · Kickstar ROMs & Turrican included.
 · Install path: $INSTALL_DIR/amiberry
 · HELP: F12 = Menu | Change your input device in the menu | Quickstart and select Disk image.
"
read -p "Press [ENTER] to continue..."

install
