#!/bin/bash
#
# Description : Diablo for Raspberry Pi
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.10 (11/Nov/21)
# Compatible  : Raspberry Pi 3-4 (tested)
#
# Help		  : https://github.com/diasurgical/devilutionX/
#

. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(p7zip libsdl2-ttf-2.0-0 libsdl2-mixer-2.0-0)
readonly BINARY_PATH="https://github.com/diasurgical/devilutionX/releases/download/1.3.0/devilutionx-linux-armhf.zip"
readonly VAR_DATA_NAME="DIABLO_1"
readonly DIABLO1_DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME")
readonly ICON="https://misapuntesde.com/res/diablo1.png"

runme() {
    echo
    read -p "Do you want to play Diablo1 now? [y/n] " option
    case "$option" in
    y*) "$INSTALL_DIR"/diablo1/devilutionx ;;
    esac
    clear
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/diablo1 ~/.local/share/applications/diablo1.desktop ~/.local/share/diasurgical
}

uninstall() {
    read -p "Do you want to uninstall Diablo 1 (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/diablo1 ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    runme
}

if [[ -d "$INSTALL_DIR"/diablo1 ]]; then
    echo -e "Diablo 1 already installed.\n"
    uninstall
    exit 1
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    wget -qO- -O "$INSTALL_DIR"/diablo1/diablo1.png "$ICON"
    if [[ ! -e ~/.local/share/applications/diablo1.desktop ]]; then
        cat <<EOF >~/.local/share/applications/diablo1.desktop
[Desktop Entry]
Name=Diablo 1
Exec=${INSTALL_DIR}/diablo1/devilutionx
Icon=${INSTALL_DIR}/diablo1/diablo1.png
Type=Application
Comment=Set in the fictional Kingdom of Khanduras in the mortal realm, Diablo makes the player take control of a lone hero battling to rid the world of Diablo
Categories=Game;ActionGame;
EOF
    fi
}

install() {
    echo -e "\nInstalling Diablo 1, please wait..."
    install_packages_if_missing "${PACKAGES[@]}"

    download_and_extract "$BINARY_PATH" "$INSTALL_DIR"
    mv "$INSTALL_DIR"/devilutionx-linux-armhf "$INSTALL_DIR"/diablo1
    generate_icon

    if ! exists_magic_file; then
        echo -e "\nNow copy diabdat.mpq (must be in lowercase) into $INSTALL_DIR/diablo1."
        exit_message
    fi

    download_file "$DIABLO1_DATA_URL" "$INSTALL_DIR"/diablo1
    echo -e "\nDone!. type $INSTALL_DIR/diablo1 to Play or go to Menu > Games > Diablo1 (if proceed).\n"
    runme
}

install_script_message
install
