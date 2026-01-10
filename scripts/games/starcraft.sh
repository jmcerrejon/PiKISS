#!/bin/bash
#
# Description : Stratagus - A free fantasy real time strategy game engine
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 2.0.0 (06/Jun/25)
# Tested      : Raspberry Pi 5
# Note        : For compiling stuff, don't install liblog4cxx-dev
#

set -euo pipefail

# shellcheck disable=SC1094
# shellcheck disable=SC1091
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(wine p7zip-full)
readonly PACKAGES_DEV=(liblua5.1-dev libtolua++5.1-dev libsdl2-image-dev libbz2-dev libmng-dev doxygen libtheora-dev libmagick++-dev libcppunit-dev)
readonly SOURCE_CODE_STRATAGUS_URL="https://github.com/Wargus/stratagus"
readonly SOURCE_CODE_STARGUS_URL="https://github.com/Wargus/stargus"
readonly SCRIPT_PATH="$HOME/games/starcraft/starcraft.sh"
readonly GAME_BINARY_PATH="https://archive.org/download/starcraft-rpi.7z/starcraft-rpi.7z"

runme() {
    if [ ! -d "$INSTALL_DIR"/starcraft ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    echo
    read -p "Press [ENTER] to run..."
    cd "$INSTALL_DIR/starcraft" && ./starcraft.sh
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/starcraft ~/.local/share/applications/starcraft.desktop
}

uninstall() {
    read -p "Do you want to uninstall StarCraft Brood War (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/starcraft ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled. NOTE: You need to uninstall wine manually with sudo apt remove -y wine"
        exit_message
    fi
    exit_message
}

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/starcraft.desktop ]]; then
        cat <<EOF >~/.local/share/applications/starcraft.desktop
[Desktop Entry]
Name=StarCraft Brood War
Exec=${INSTALL_DIR}/starcraft/starcraft.sh
Icon=${INSTALL_DIR}/starcraft/icon.png
Path=${INSTALL_DIR}/starcraft/
Type=Application
Comment=StarCraft: Brood War is the expansion pack for the military science fiction real-time strategy video game StarCraft.
Categories=Game;ActionGame;
EOF
    fi
}

compile_stratagus() {
    echo -e "\nInstalling dependencies (If proceed)...\n"
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    echo -e "\nCloning repository...\n"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    git clone --recursive "$SOURCE_CODE_STRATAGUS_URL" stratagus && cd "$_" || exit 1
    mkdir -p build && cd "$_" || exit 1
    cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DENABLE_STATIC=ON
    echo -e "\nCompiling...\n"
    make_with_all_cores
}

compile_stargus() {
    STRATAGUS_GAME_LAUNCHER_H_PATH="$HOME/sc/stratagus/gameheaders/stratagus-game-launcher.h"
    STRATAGUS_BINARY_PATH="$HOME/sc/stratagus/build/stratagus"
    echo -e "\nInstalling dependencies (If proceed)...\n"
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    echo -e "\nCloning repository...\n"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    git clone --recursive "$SOURCE_CODE_STARGUS_URL" stargus && cd "$_" || exit 1
    meson build
    if [[ ! -e $STRATAGUS_GAME_LAUNCHER_H_PATH ]]; then
        echo -e "$STRATAGUS_GAME_LAUNCHER_H_PATH not found. Please run the script again."
        error_message
    fi
    if [[ ! -e $STRATAGUS_BINARY_PATH ]]; then
        echo -e "$STRATAGUS_BINARY_PATH not found. Please run the script again."
        error_message
    fi
    echo -e "\nCompiling...\n"
    ninja -C build -j "$(nproc)" -DSTRATAGUS_INCLUDE_DIR="$STRATAGUS_GAME_LAUNCHER_H_PATH" -DSTRATAGUS_BIN="$STRATAGUS_BINARY_PATH"
    ninja -C build -j "$(nproc)" -DSTRATAGUS_INCLUDE_DIR="$HOME/sc/stratagus/gameheaders/stratagus-game-launcher.h" -DSTRATAGUS_BIN="$HOME/sc/stratagus/build/stratagus"
    make_with_all_cores
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$GAME_BINARY_PATH" "$INSTALL_DIR"
    generate_icon
    echo -e "\nDone. Go to Menu > Games > StarCraft Brood War or type $INSTALL_DIR/starcraft/starcraft.sh"
    runme
}

if [ -f "/usr/local/bin/twistver" ]; then
    echo "Sorry, It's not recommended to install StarCraft Brood War on Twister OS due to conflicts with x86 wine. Apologies."
    exit_message
fi

if [[ -d "$INSTALL_DIR"/starcraft ]]; then
    echo -e "StarCraft Brood War already installed.\n"
    uninstall
    exit 1
fi

install_script_message
echo "
Install StarCraft + Brood War
=============================

 · Thanks Blizzard for release free this game in 2017.
 · Install path: $INSTALL_DIR/starcraft

"

install
