#!/bin/bash
#
# Description : Hurrican
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.0 (10/Nov/25)
# Tested      : Raspberry Pi 5 (tested)
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
. ../helper.sh || . ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES_DEV=(libepoxy-dev libegl1-mesa-dev libdtovl-dev)
readonly SOURCE_CODE_URL="https://github.com/HurricanGame/Hurrican"
readonly BINARY_URL="https://misapuntesde.com/rpi_share/hurrican_rpi.tar.gz"
readonly BINARY_64_BITS_URL="https://misapuntesde.com/rpi_share/hurrican-rpi-aarch64.tar.gz"

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
Comment=Freeware jump and shoot game based on the Turrican game series
Categories=Game;ActionGame;
EOF
    fi
}

install() {
    local BINARY_URL_INSTALL=$BINARY_URL

    if is_userspace_64_bits; then
        BINARY_URL_INSTALL=$BINARY_64_BITS_URL
    fi
    echo -e "\n\nInstalling, please wait..."
    download_and_extract "$BINARY_URL_INSTALL" "$INSTALL_DIR"
    generate_icon
    echo -e "\nType in a terminal $INSTALL_DIR/hurrican/hurrican or go to Menu > Games > Hurrican."
    runme
}

install_script_message
echo "
Hurrican Raspberry Pi
=====================

· Freeware jump and shoot game based on the Turrican game series.
· More Info: $SOURCE_CODE_URL
"

read -p "Press [ENTER] to continue..."

install
