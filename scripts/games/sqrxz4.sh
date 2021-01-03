#!/bin/bash
#
# Description : Sqrxz4 game installation
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.0 (03/Jan/21)
# Compatible  : Raspberry Pi 1, 2 & 3 (tested)
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly BINARY_FILE="https://www.retroguru.com/sqrxz4/sqrxz4-v.latest-raspberrypi.zip"

remove_files() {
    sudo rm -rf "$INSTALL_DIR/sqrxz4" ~/.local/share/applications/sqrxz4.desktop
}

uninstall() {
    read -p "Do you want to uninstall Sqrxz4 (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/scrcpy ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d $INSTALL_DIR/sqrxz4 ]]; then
    echo -e "Sqrxz4 already installed.\n"
    uninstall
    exit 1
fi

generate_icon() {
    echo "Generating icon..."
    if [[ ! -e ~/.local/share/applications/sqrxz4.desktop ]]; then
        cat <<EOF >~/.local/share/applications/sqrxz4.desktop
[Desktop Entry]
Name=Sqrxz4
Exec=${PWD}/sqrxz4_rpi
Path=${PWD}/
Icon=terminal
Type=Application
Comment=The fourth part of the (now) quadrology Jump and Think series Sqrxz brings you onto an cold icy island.
Categories=Game;ActionGame;
EOF
    fi
}

install() {
    mkdir -p "$INSTALL_DIR" && cd "$_" || exit 1
    download_and_extract "$BINARY_FILE" "$INSTALL_DIR/sqrxz4"
    generate_icon
    echo -e "Done!. To play, on Desktop go to Menu > Games or via terminal, go to $INSTALL_DIR and type: ./sqrxz4_rpi\n\nEnjoy!"
    read -p "Press [Enter] to continue..."
    exit
}

install_script_message
echo "
Install Xump (Raspberry Pi version)
===================================

· More Info: https://www.retroguru.com/xump/
· Install path: $INSTALL_DIR/sqrxz4
"

install
