#!/bin/bash
#
# Description : Sonic Robo Blast 2
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (22/Jan/22)
# Compatible  : Raspberry Pi 4 (tested)
# URL         : https://www.srb2.org/ | https://wiki.srb2.org/wiki/Main_Page
# Thks to     : @Foxhound311 for the binary version

. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libsdl2-mixer-2.0-0 libsdl2-image-2.0-0)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/srb2-rpi.tar.gz"

runme() {
    echo
    if [[ ! -d $INSTALL_DIR/srb2 ]]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR/srb2" && ./srb2
    clear
    exit_message
}

remove_files() {
    sudo rm -rf "$INSTALL_DIR/srb2" ~/.srb2 ~/.local/share/applications/srb2.desktop
}

uninstall() {
    read -p "Do you want to uninstall Sonic Robo Blast 2 (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e $INSTALL_DIR/srb2 ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d $INSTALL_DIR/srb2 ]]; then
    echo -e "Sonic Robo Blast 2 already installed.\n"
    uninstall
    exit 0
fi

generate_icon() {
    echo -e "\nGenerating icons..."
    if [[ ! -e ~/.local/share/applications/srb2.desktop ]]; then
        cat <<EOF >~/.local/share/applications/srb2.desktop
[Desktop Entry]
Name=Sonic Robo Blast 2
Exec=${INSTALL_DIR}/srb2/srb2
Icon=${INSTALL_DIR}/srb2/icon.png
Path=${INSTALL_DIR}/srb2
Type=Application
Comment=3D platformer fangame based on the Sonic the Hedgehog series.
Categories=Game;ActionGame;
EOF
    fi
}

install() {
    echo -e "Installing Sonic Robo Blast 2..."
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    generate_icon
    echo -e "\nDone!. You can play typing $INSTALL_DIR/srb2 or opening the Menu > Games > Sonic Robo Blast 2."
}

install_script_message
echo "
Sonic Robo Blast 2
==================

· 3D platformer fangame based on the Sonic the Hedgehog series.
· Thks @Foxhound311 for the binary version.
"

install
runme
