#!/bin/bash
#
# Description : Wipeout
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (9/Jun/24)
# Tested on   : Raspberry Pi 5
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libglew2.2)
readonly PACKAGES_DEV=(cmake libglew-dev libsdl2-dev libx11-dev libxcursor-dev libxi-dev libasound2-dev)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/wipeout-rpi-aarch64.tar.gz"
readonly GAME_DATA_URL="https://phoboslab.org/files/wipeout-data-v01.zip"
readonly SOURCE_CODE_URL="https://github.com/phoboslab/wipeout-rewrite"

runme() {
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/wipeout && ./wipegame
    exit_message
}

remove_files() {
    sudo rm -rf "$INSTALL_DIR"/wipeout ~/.local/share/wipeoutpc ~/.local/share/applications/wipeout.desktop
}

uninstall() {
    read -p "Do you want to uninstall Wipeout (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/wipeout ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/wipeout ]]; then
    echo -e "Wipeout already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\n\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/wipeout.desktop ]]; then
        cat <<EOF >~/.local/share/applications/wipeout.desktop
[Desktop Entry]
Name=Wipeout
Exec=${INSTALL_DIR}/wipeout/wipegame
Icon=${INSTALL_DIR}/wipeout/wipeout.ico
Path=${INSTALL_DIR}/wipeout
Type=Application
Comment=This is a re-implementation of the 1995 PSX game wipEout.
Categories=Game;ActionGame;
EOF
    fi
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    [[ -d $HOME/sc/wipeout ]] && rm -rf "$HOME/sc/wipeout"
    git clone "$SOURCE_CODE_URL" wipeout && cd "$_" || exit 1
    echo -e "\n\nCompiling... Estimated time on RPi 4: < 5 min.\n"
    time make sdl
    echo "Done!. Check the $HOME/sc/wipeout folder."
}

install() {
    echo -e "\n\nInstalling, please wait..."
    install_packages_if_missing "${PACKAGES[@]}"

    if ! is_userspace_64_bits; then
        echo "Sorry, only 64-bit OS is supported."
        exit_message
    fi

    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    generate_icon
    echo -e "\n\nDone!. You can play typing $INSTALL_DIR/wipeout/wipeout or opening the Menu > Games > Wipeout.\n"
    echo -e "ALT+ENTER full-screen | [ENTER] Select | Cursor for move | A - Run | Z - Jump | X - Twist | P - Pause | C-V Move Camera |  Shift+F1-F10 - Save | F1-F10 - Load snapshot.\n"
    runme
}

install_script_message
echo "
wipEout Rewrite
===============

 · Wipeout is a series of futuristic anti-gravity racing video games developed by Studio Liverpool (formerly known as Psygnosis).
 · Based on the work from phoboslab | https://github.com/phoboslab
 · Native for Raspberry Pi. No emulator needed.
 · KEYS: ALT+ENTER full-screen | [ENTER] Select | Cursor for move | A - Run | Z - Jump | X - Twist | P - Pause | C-V Move Camera |  Shift+F1-F10 - Save | F1-F10 - Load snapshot.
 · For more KEYS & info, visit $SOURCE_CODE_URL
"

install
