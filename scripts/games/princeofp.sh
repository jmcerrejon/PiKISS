#!/bin/bash
#
# Description : Prince Of Persia
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.1 (25/Sep/21)
# Compatible  : Raspberry Pi 4 (tested)
# Repository  : https://github.com/NagyD/SDLPoP
#
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libsdl2-image-2.0-0)
readonly PACKAGES_DEV=(libsdl2-image-dev)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/prince-1.21-rpi.tar.gz"
readonly SOURCE_CODE_URL="https://github.com/NagyD/SDLPoP"

runme() {
    if [[ ! -d "$INSTALL_DIR"/prince ]]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/prince && ./prince
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/prince ~/.local/share/applications/prince.desktop
}

uninstall() {
    read -p "Do you want to uninstall Prince Of Persia (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/prince ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/prince ]]; then
    echo -e "Prince Of Persia already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/prince.desktop ]]; then
        cat <<EOF >~/.local/share/applications/prince.desktop
[Desktop Entry]
Name=Prince Of Persia
Version=1.0
Type=Application
Comment=An open-source port of Prince of Persia, based on the disassembly of the DOS version, extended with new features.
Exec=${INSTALL_DIR}/prince/prince
Icon=${INSTALL_DIR}/prince/icon.ico
Path=${INSTALL_DIR}/prince/
Terminal=false
Categories=Game;
EOF
    fi
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    git clone "$GITHUB_URL" prince && cd "$_"/src || exit 1
    make_with_all_cores "\nCompiling..."
    make_install_compiled_app
    echo -e "\nDone!. Check the code at $HOME/sc/prince"
    exit_message
}

download_binaries() {
    echo -e "\nInstalling binary files..."
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    download_binaries
    generate_icon
    echo -e "\nDone!. You can play typing $INSTALL_DIR/prince/prince or opening the Menu > Games > Prince Of Persia.\n"
    runme
}

install_script_message
echo "
Prince Of Persia for Raspberry Pi
=================================

 · This port has some interesting features/tweaks. Open the menu with ESC and dive into it.
 · Visit $SOURCE_CODE_URL for more info.
 · Gamepad support.
 · KEYS: Arrows = Move | Shift = Pick up things | Shift+Left/Right: careful step.
 · +KEYS: ALT+ENTER = Full Screen | CTRL+A = Restart Level | CTRL+G orF6 = Save Game / Quick Save | CTRL+L or F9 = Load Game / Quick Load.
"
read -p "Press [Enter] to continue..."
install
