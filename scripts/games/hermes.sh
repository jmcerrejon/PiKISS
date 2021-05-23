#!/bin/bash
#
# Description : Hermes
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (23/May/21)
# Compatible  : NOT WORKING ON Raspberry Pi 4 (tested)
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly BINARY_URL="https://www.retroguru.com/hermes/hermes-v.latest-raspberrypi.zip"

runme() {
    [[ ! -e $INSTALL_DIR/hermes/hermes_rpi ]] && exit_message

    read -p "Do you want to play now (Y/n)? " response
    if [[ $response =~ [Nn] ]]; then
        exit_message
    fi
    cd "$INSTALL_DIR/hermes" && ./hermes_rpi
    exit_message
}

uninstall() {
    read -p "Do you want to uninstall Hermes (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR/hermes" ~/.local/share/applications/Hermes.desktop
        if [[ -e $INSTALL_DIR/hermes/hermes_rpi ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if which "$INSTALL_DIR/hermes/hermes_rpi" >/dev/null; then
    echo -e "Hermes already installed.\n"
    uninstall
fi

generate_icon() {
    echo "Downloading & Generating icon..."
    download_file https://www.retroguru.com/icons/games/hermes.gif "$INSTALL_DIR/hermes/"
    if [[ ! -e ~/.local/share/applications/Hermes.desktop ]]; then
        cat <<EOF >~/.local/share/applications/Hermes.desktop
[Desktop Entry]
Name=Hermes
Exec=${INSTALL_DIR}/hermes/hermes_rpi
Icon=${INSTALL_DIR}/hermes/hermes.gif
Path=${INSTALL_DIR}/hermes/
Type=Application
Comment=Jump'n' Run game with plenty of bad taste humour. If you feel offended by crude and dirty humour you may run away now.
Categories=Game;ActionGame;
EOF
    fi
}

install() {
    mkdir -p "$INSTALL_DIR/hermes" && cd "$_" || exit 1
    download_and_extract "$BINARY_URL" "$INSTALL_DIR/hermes"
    chmod +x hermes_rpi
    generate_icon
    echo -e "\nDone!. To play, on Desktop go to Menu > Games or via terminal, go to $INSTALL_DIR and type: ./hermes_rpi\n\nEnjoy!"
    runme
}

install_script_message
echo "
Install Hermes
==============

· More Info: https://www.retroguru.com/hermes/
· Install path: $INSTALL_DIR/hermes
"

install
