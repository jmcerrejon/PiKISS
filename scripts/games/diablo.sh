#!/bin/bash
#
# Description : Diablo for Raspberry Pi
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.2.0 (29/Mar/25)
# Compatible  : Raspberry Pi 3-4 (tested)
#
# Help		  : https://github.com/diasurgical/devilutionX/
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(p7zip libsdl2-ttf-2.0-0 libsdl2-mixer-2.0-0)
readonly BINARY_URL="https://github.com/diasurgical/devilutionX/releases/download/1.3.0/devilutionx-linux-armhf.zip"
readonly BINARY_64_BITS_URL="https://github.com/diasurgical/DevilutionX/releases/download/1.5.4/devilutionx-linux-aarch64.tar.xz"
readonly SHAREWARE_URL="https://github.com/diasurgical/devilutionx-assets/releases/latest/download/spawn.mpq"
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

uninstall() {
    read -p "Do you want to uninstall Diablo 1 (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR"/diablo1 ~/.local/share/applications/diablo1.desktop ~/.local/share/diasurgical
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

download_data_files() {
    if exists_magic_file; then
        echo -e "\nDownloading Data..."
        DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME")
        message_magic_air_copy "DIABLO 1"
        download_file "$DATA_URL" "$INSTALL_DIR"/diablo1
        return 0
    else
        echo -e "\nDownloading shareware version..."
        download_file "$SHAREWARE_URL" "$INSTALL_DIR"/diablo1
        return 0
    fi
}

install_binaries() {
    echo -e "\nInstalling, please wait..."
    if is_userspace_64_bits; then
        download_and_extract "$BINARY_64_BITS_URL" "$INSTALL_DIR/diablo1"
    else
        download_and_install "$BINARY_URL" "$INSTALL_DIR"
    fi

    [[ -e "$INSTALL_DIR/devilutionx-linux-armhf" ]] && mv "$INSTALL_DIR/devilutionx-linux-armhf" "$INSTALL_DIR"/diablo1
    [[ -e "$INSTALL_DIR/diablo1/devilutionx.deb" ]] && rm "$INSTALL_DIR/diablo1/devilutionx.deb"
    [[ -e "$INSTALL_DIR/diablo1/devilutionx.rpm" ]] && rm "$INSTALL_DIR/diablo1/devilutionx.rpm"

    return 0
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"

    install_binaries
    download_data_files
    generate_icon

    echo -e "\nDone! Type $INSTALL_DIR/diablo1 to play or go to Menu > Games > Diablo 1.\n"
    runme
}

install_script_message
echo "
Diablo 1
========
· The game needs the original game files to play it, but a shareware version will be installed.
· Thanks to DevilutionX for the port.
"

install
