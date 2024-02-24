#!/bin/bash
#
# Description : RVGL (AKA Revolt) is a radio control car racing themed video game.
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 2.0.0 (24/Feb/24)
# Tested      : Raspberry Pi 5
#
# HELP	      : https://distribute.re-volt.io
# TODO	      : Add https://gitlab.com/re-volt/rvgl-launcher & https://re-volt.gitlab.io/rvgl-launcher/home.html, https://gitlab.com/re-volt/rvgl-installer
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games/rvgl"
readonly PACKAGES=(libenet7)
readonly GAME_PATH="https://distribute.re-volt.io/releases/rvgl_full_linux_original.zip"
readonly GAME_DATA_PATH="https://misapuntesde.com/rpi_share/rvgl-data.deb"
readonly WEBSITE_URL="https://distribute.re-volt.io"
readonly DOCUMENTATION_URL="https://re-volt.gitlab.io/rvgl-docs"

uninstall() {
    echo
    read -p "Do you want to uninstall RVGL (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf ~/.local/share/applications/RVGL.desktop "$INSTALL_DIR"
        if [[ -e $INSTALL_DIR ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -e $INSTALL_DIR ]]; then
    echo "Warning!: RVGL already installed."
    uninstall
fi

clean_unused_data() {
    cd "$INSTALL_DIR" || exit 1
    rm -rf rvgl.32 rvgl.64
}

install_game() {
    echo -e "\nInstalling RVGL..."
    install_packages_if_missing "${PACKAGES[@]}"
    mkdir -p "$INSTALL_DIR" && cd "$_" || exit 1
    download_and_extract "$GAME_PATH" "$INSTALL_DIR"
}

install() {
    install_game
    echo -e "\nInstalling RVGL data..."
    cd "$INSTALL_DIR" || exit 1
    mkdir -p ./cache ./profiles ./replays ./times
    ./setup
    clean_unused_data
    echo -e "\nDone!. Go to Menu Games > RVGL or cd into $INSTALL_DIR and type: ./rvgl"
    exit_message
}

install_script_message
echo "
RVGL (AKA Re-Volt)
==================

 · Re-Volt is a radio control car racing themed video game.
 · The game has been ported to modern systems and is still being played today.
 · More info: $WEBSITE_URL | $DOCUMENTATION_URL"

install
