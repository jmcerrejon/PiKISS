#!/bin/bash

#
# Description : MAME
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 2.0.0 (3/Apr/22)
# Compatible  : Raspberry Pi 4
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }
clear

readonly INSTALL_DIR="$HOME/games"
readonly BINARY_URL="https://stickfreaks.com/mame/mame_0.243_armhf_gcc8.7z"
readonly BINARY_64_BITS_URL="https://stickfreaks.com/mame/mame_0.243_aarch64_gcc8.7z"
readonly PACKAGES=(p7zip libfreetype6 libsdl2-ttf-2.0-0 libsdl2-2.0-0 libqt5widgets5 libqt5gui5)
readonly ROMS_URL="https://misapuntesde.com/res/galaxian.zip"
readonly INPUT=/tmp/temp.$$

uninstall() {
    read -p "Do you want to uninstall MAME (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR/mame" ~/.local/share/applications/mame.desktop
        if [[ -e $INSTALL_DIR/mame ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d $INSTALL_DIR/mame ]]; then
    echo -e "MAME already installed.\n"
    uninstall
    exit 1
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/mame.desktop ]]; then
        cat <<EOF >~/.local/share/applications/mame.desktop
[Desktop Entry]
Name=MAME
Version=1.0
Type=Application
Comment=Multiple Arcade Machine Emulator
Exec=${INSTALL_DIR}/mame/mame
Icon=${INSTALL_DIR}/mame/docs/source/images/MAMElogo.svg
Path=${INSTALL_DIR}/mame/
Terminal=false
Categories=Game;Emulator;
EOF
    fi
}

downloadROM() {
    echo -e "\nCopying ROM to $1..."
    [[ ! -d $1 ]] && mkdir -p "$1"
    download_file "$ROMS_URL" "$1"
}

install() {
    local BINARY_URL_INSTALL=$BINARY_URL

    if is_userspace_64_bits; then
        BINARY_URL_INSTALL=$BINARY_64_BITS_URL
    fi

    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL_INSTALL" "$INSTALL_DIR/mame"
    downloadROM "$INSTALL_DIR/mame/roms"
    generate_icon
    echo -e "\nDone!. To play, go to $INSTALL_DIR/mame and run the binary or on Desktop, Menu > games > MAME."
    exit_message
}

echo "
MAME 0.242
==========

· More info: https://stickfreaks.com/mame/ | https://www.mamedev.org/?p=511
· KEYS: F3=RESET | F7=Load | Shift+F7=Save | 5=Add 1 Credit Player 1 | 1=Start Player 1 | ESC=Exit
"
install
