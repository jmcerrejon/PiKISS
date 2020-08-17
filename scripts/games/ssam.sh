#!/bin/bash
#
# Description : Serious Sam The Second Encounter thks to Pi Labs & ptitSeb
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.1 (17/Aug/20)
# Compatible  : Raspberry Pi 4 (tested)
#
# Help        : https://www.raspberrypi.org/forums/viewtopic.php?t=200458
#

. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"
BINARY_PATH="https://misapuntesde.com/rpi_share/ssam-tse_1.10-669dc91_armhf.tar.xz"

runme() {
    echo
    if [ ! -f "$INSTALL_DIR"/ssam-tse/ssam-tse.sh ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/ssam-tse && ./ssam-tse.sh
    clear
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/ssam-tse ~/.local/share/applications/ssam-tse.desktop
}

uninstall() {
    read -p "Do you want to uninstall it (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/ssam-tse ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/ssam-tse ]]; then
    echo -e "Serious Sam The Second Encounter already installed.\n"
    uninstall
    exit 1
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/ssam-tse.desktop ]]; then
        cat <<EOF >~/.local/share/applications/ssam-tse.desktop
[Desktop Entry]
Name=Serious Sam The Second Encounter
Exec=${HOME}/games/ssam-tse/ssam-tse.sh
Icon=${HOME}/games/ssam-tse/ssam-tse.png
Path=${HOME}/games/ssam-tse/Serious-Engine/Bin
Type=Application
Comment=After the events of The First Encounter, Serious Sam is seen traveling through space in the SSS Centerprice...
Categories=Game;ActionGame;
EOF
    fi
}

fix_libEGL() {
    if [[ -f /opt/vc/lib/libEGL.so ]]; then
        echo -e "\nFixing libEGL.so..."
        touch "$INSTALL_DIR"/ssam-tse/Serious-Engine/Bin/libEGL.so
    fi
}

show_readme() {
    if [[ -f /usr/bin/mousepad ]]; then
        echo -e "\nClose Mousepad to continue..."
        mousepad ~/games/ssam-tse/README-tse-binary.md >/dev/null 2>&1
    fi
}

install_binaries() {
    download_and_extract "$BINARY_PATH" "$INSTALL_DIR"/ssam-tse 
    show_readme
    echo -e "\nDone!. Now follow the instructions to copy the data files from https://github.com/ptitSeb/Serious-Engine"
    exit_message
}

install_full_version() {
    BINARY_PATH=$(extract_url_from_file 10)
    message_magic_air_copy
    download_and_extract "$BINARY_PATH" "$INSTALL_DIR"
    fix_libEGL
    generate_icon
    echo -e "\nType in a terminal $INSTALL_DIR/ssam-tse/ssam-tse.sh or go to Menu > Games > Serious Sam The Second Encounter."
    runme
}

install() {
    echo -e "\nInstall Serious Sam The Second Encounter"
    echo
    read -p "Do you have an original copy of Serious Sam The Second Encounter (If not, only the binaries will be installed) (Y/n)?: " response
    if [[ $response =~ [Nn] ]]; then
        install_binaries
    fi

    install_full_version
}

install
