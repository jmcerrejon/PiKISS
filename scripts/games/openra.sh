#!/bin/bash
#
# Description : OpenRA
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (10/Jul/26)
# Tested      : Raspberry Pi 5
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly GAME_NAME="OpenRA"
readonly INSTALL_DIR="$HOME/games"
readonly APP_DIR="$INSTALL_DIR/openra"
readonly PACKAGES=(libopenal1)
readonly PACKAGES_DEV=(git-all make g++ libopenal-dev libsdl2-dev libfreetype6-dev libfontconfig1-dev)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/openra-aarch64.tar.gz"
readonly SOURCE_CODE_URL="https://github.com/OpenRA/OpenRA"

runme() {
    if [ ! -f "$APP_DIR"/openra.sh ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$APP_DIR" || exit 1
    ./openra.sh
    exit_message
}

remove_files() {
    rm -rf "$APP_DIR" ~/.local/share/applications/openra.desktop ~/.config/openra
}

uninstall() {
    read -p "Do you want to uninstall $GAME_NAME (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$APP_DIR" ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$APP_DIR" ]]; then
    echo -e "$GAME_NAME already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/openra.desktop ]]; then
        cat <<EOF >~/.local/share/applications/openra.desktop
[Desktop Entry]
Name=OpenRA
Exec=${APP_DIR}/openra.sh
Icon=${APP_DIR}/mods/ra/icon.png
Path=${APP_DIR}/
Type=Application
Terminal=false
Comment=Open-source reimplementation of the classic Command & Conquer real-time strategy games.
Categories=Game;StrategyGame;
EOF
    fi
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    git clone "$SOURCE_CODE_URL" openra && cd "$_" || exit 1
    make all
    echo -e "\nDone!. Check the code at $HOME/sc/openra"
    exit_message
}

install() {
    if ! is_userspace_64_bits; then
        echo -e "\nSorry, only 64-bit OS is supported."
        exit_message
    fi

    echo -e "\n\nInstalling OpenRA, please wait..."
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    if [[ -d "$INSTALL_DIR/OpenRA" ]] && [[ ! -d "$APP_DIR" ]]; then
        mv "$INSTALL_DIR/OpenRA" "$APP_DIR"
    fi
    generate_icon
    echo -e "\nDone!. You can play typing $APP_DIR/openra.sh or opening the Menu > Games > OpenRA.\n"
    runme
}

install_script_message
echo "
OpenRA
======

 · Open-source engine for classic RTS games from the Command & Conquer saga.
 · This installer is available for aarch64 (64-bit OS).
 · More info: $SOURCE_CODE_URL
"
read -p "Press [Enter] to continue..."

install
