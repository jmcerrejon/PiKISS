#!/bin/bash
#
# Description : Super Mario War
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (16/Jan/22)
# Compatible  : Raspberry Pi 4 (tested)
# URL         : https://www.retrogames.com/super-mario-war/
# Thks to     : @Foxhound311 for the binary version

. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libsdl2-mixer-2.0-0 libsdl2-image-2.0-0)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/smw-rpi.tar.gz"

runme() {
    echo
    if [[ ! -d $INSTALL_DIR/smw-netplay ]]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR/smw-netplay" && ./smw
    clear
    exit_message
}

remove_files() {
    sudo rm -rf "$INSTALL_DIR/smw-netplay" ~/.smw ~/.local/share/applications/smw.desktop
}

uninstall() {
    read -p "Do you want to uninstall Super Mario War (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e $INSTALL_DIR/smw-netplay ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d $INSTALL_DIR/smw-netplay ]]; then
    echo -e "Super Mario War already installed.\n"
    uninstall
    exit 0
fi

generate_icon() {
    echo -e "\n\nGenerating icons..."
    if [[ ! -e ~/.local/share/applications/smw.desktop ]]; then
        cat <<EOF >~/.local/share/applications/smw.desktop
[Desktop Entry]
Name=Super Mario War
Exec=${INSTALL_DIR}/smw-netplay/smw
Icon=${INSTALL_DIR}/smw-netplay/icon.png
Path=${INSTALL_DIR}/smw-netplay
Type=Application
Comment=The game centers on players fighting each other by one player jumping on the other player's head, or by making use of items, which can be picked up during gameplay.
Categories=Game;ActionGame;
EOF
    fi
}

post_install() {
    generate_icon
    cp -r "$INSTALL_DIR/smw-netplay/.smw" "$HOME"
}

install() {
    echo -e "Installing Super Mario War..."
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    post_install
    echo -e "\nDone!. You can play typing $INSTALL_DIR/smw-netplay or opening the Menu > Games > Super Mario War."
}

install_script_message
echo "
Super Mario War
===============

· The game centers on players fighting each other by one player jumping on the other player's head, or by making use of items.
· Thks @Foxhound311 for the binary version.
"

install
runme
