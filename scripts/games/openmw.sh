#!/bin/bash
#
# Description : OpenMW (The Elder Scrolls III: Morrowind engine)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.0 (22/Nov/25)
# Tested      : Raspberry Pi 5
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
. ../helper.sh || . ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libboost-filesystem1.88.0 libboost-program-options1.88.0 libbullet3.24t64 libmyguiengine3debian1t64 libunshield0 libopenscenegraph161)
readonly PACKAGES_DEV=(libopenscenegraph-dev libopenthreads20)
readonly GITHUB_PATH="svn://svn.code.sf.net/p/openmw-emu/code/tags/v3.4/"
readonly ES_TRANSLATION_URL="https://misapuntesde.com/rpi_share/morrowind-es-mod.tar.gz"
readonly VAR_DATA_NAME="OPENMW_FULL"
BINARY_URL="https://archive.org/download/openmw-0.46-rpi.tar/openmw-0.46-rpi.tar.gz"
BINARY_64_BITS_URL="https://media.githubusercontent.com/media/jmcerrejon/pikiss-bin/refs/heads/main/games/openmw-0.51-rpi-aarch64.tar.gz"

runme() {
    if [ ! -f "$INSTALL_DIR/openmw/openmw-launcher" ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run..."
    cd "$INSTALL_DIR"/openmw && ./openmw-launcher
    exit_message
}

remove_files() {
    [[ -d "$INSTALL_DIR"/openmw ]] && rm -rf "$INSTALL_DIR"/openmw ~/.config/openmw ~/.local/share/applications/openmw.desktop ~/.local/share/openmw
}

uninstall() {
    read -p "Do you want to uninstall OpenMW (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/openmw ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -e $INSTALL_DIR/openmw ]]; then
    echo -e "OpenMW already installed.\n"
    uninstall
fi

generate_icon() {
    if [[ ! -e ~/.local/share/applications/openmw.desktop ]]; then
        cat <<EOF >~/.local/share/applications/openmw.desktop
[Desktop Entry]
Name=OpenMW
Exec=${INSTALL_DIR}/openmw/openmw-launcher
Path=${INSTALL_DIR}/openmw/
Icon=${INSTALL_DIR}/openmw/icon.png
Type=Application
Comment=The Elder Scrolls III: Morrowind is an open-world RPG developed by Bethesda Game Studios and published by Bethesda Softworks.
Categories=Game;
EOF
    fi
}

download_data_files() {
    if exists_magic_file; then
        echo -e "\nInstalling data files..."
        DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME")
        message_magic_air_copy "$VAR_DATA_NAME"
        download_and_extract "$DATA_URL" "$INSTALL_DIR/openmw"
    fi
}

install() {
    local BINARY_URL_INSTALL=$BINARY_URL

    install_packages_if_missing "${PACKAGES[@]}"

    if is_userspace_64_bits; then
        BINARY_URL_INSTALL=$BINARY_64_BITS_URL
    fi
    download_and_extract "$BINARY_URL_INSTALL" "$INSTALL_DIR"
    generate_icon
    download_data_files
    echo -e "\nDone!. You can play typing $INSTALL_DIR/openmw/openmw.sh or opening the Menu > Games > OpenMW.\n"
    runme
}

install_script_message
echo "
OpenMW for Raspberry Pi
=======================

 · Install path: $INSTALL_DIR/openmw
 · REMEMBER YOU NEED A LEGAL COPY OF THE GAME and copy neccessary files from your Morrowind installation to the OpenMW folders.
 · More info at https://openmw.org/
 · Wanna the best for this game?. Follow the Morrowind graphics guide at https://wiki.nexusmods.com/index.php/Morrowind_graphics_guide
"
read -p "Press [ENTER] to continue..."

install
