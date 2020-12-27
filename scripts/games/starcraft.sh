#!/bin/bash
#
# Description : StarCraft Brood War
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.2 (27/Dec/20)
# Compatible  : Raspberry Pi 4 (tested)
#

. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly SCRIPT_PATH="$HOME/games/starcraft/starcraft.sh"
readonly BINARY_PATH="https://archive.org/download/starcraft-rpi.7z/starcraft-rpi.7z"
readonly PACKAGES=(wine p7zip-full)

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

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_PATH" "$INSTALL_DIR"
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

 · Thanks to PI Labs, Notaz, and Blizzard for release free this game in 2017.
 · Install path: $INSTALL_DIR/starcraft
 · This game uses Wine from the repo. If you set emulate a virtual desktop using winecfg previously, you can disable it to support full screen.
"

install
