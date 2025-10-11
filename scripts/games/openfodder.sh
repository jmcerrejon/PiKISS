#!/bin/bash
#
# Description : OpenFodder (A Cannon Fodder engine)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (11/Oct/25)
# Tested      : Raspberry Pi 5
#
# shellcheck disable=SC1091
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libsdl2-2.0-0 libsdl2-mixer-2.0-0 libsdl2-ttf-2.0-0)
readonly PACKAGES_DEV=(liblua5.1-dev libtolua++5.1-dev libsdl2-image-dev libbz2-dev libmng-dev doxygen libtheora-dev libmagick++-dev libcppunit-dev)
readonly SOURCE_CODE_URL="https://github.com/OpenFodder/openfodder"
readonly GAME_BINARY_PATH="https://misapuntesde.com/rpi_share/openfodder-v1.9.2-aarch64.tar.gz
"

runme() {
    if [ ! -d "$INSTALL_DIR"/openfodder ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    echo
    read -p "Press [ENTER] to run..."
    cd "$INSTALL_DIR/openfodder" && ./openfodder
    exit_message
}

uninstall() {
    read -p "Do you want to uninstall OpenFodder (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR"/openfodder ~/.local/share/applications/openfodder.desktop
        if [[ -e "$INSTALL_DIR"/openfodder ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/openfodder ]]; then
    echo -e "OpenFodder already installed.\n"
    uninstall
    exit 1
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/openfodder.desktop ]]; then
        cat <<EOF >~/.local/share/applications/openfodder.desktop
[Desktop Entry]
Name=OpenFodder
Exec=${INSTALL_DIR}/openfodder/openfodder
Icon=${INSTALL_DIR}/openfodder/FreeDesktop/openfodder.png
Path=${INSTALL_DIR}/openfodder/
Type=Application
Comment=OpenFodder is a free and open-source reimplementation of the classic Cannon Fodder games.
Categories=Game;ActionGame;
EOF
    fi
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$GAME_BINARY_PATH" "$INSTALL_DIR"
    generate_icon
    echo -e "\nDone. Go to Menu > Games > OpenFodder or type $INSTALL_DIR/openfodder/openfodder.sh"
    runme
}

install_script_message
echo "
OpenFodder (Cannon Fodder)
==========================

 • Open-source engine requiring original Cannon Fodder data files.
 • Install path: $APP_DIR
 • Place your game data in: $APP_DIR/data
   - Example: copy files from your DOS/Amiga/CD version into that folder.
 • Run:
   - Menu > Games > OpenFodder
   - or: $APP_DIR/openfodder.sh
"

install
