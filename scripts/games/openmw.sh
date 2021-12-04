#!/bin/bash
#
# Description : OpenMW (The Elder Scrolls III: Morrowind engine)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.11 (04/Dec/21)
# Compatible  : Raspberry Pi 3-4
# TODO        : Fix icon.png
#
source ../helper.sh || source ./scripts/helper.sh || source ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libqtgui4 libboost-filesystem1.67.0 libboost-program-options1.67.0 libbullet2.87 libmyguiengine3debian1v5 libunshield0)
readonly PACKAGES_DEV=(libopenscenegraph-3.4-131 libopenthreads20 libopenscenegraph-3.4-131 libopenscenegraph-3.4-131 libopenscenegraph-3.4-131 libopenscenegraph-3.4-131 libopenscenegraph-3.4-131)
readonly GITHUB_PATH="svn://svn.code.sf.net/p/openmw-emu/code/tags/v3.4/"
readonly ES_TRANSLATION_URL="https://misapuntesde.com/rpi_share/morrowind-es-mod.tar.gz"
readonly VAR_DATA_NAME="OPENMW_FULL"
BINARY_URL="https://archive.org/download/openmw-0.46-rpi.tar/openmw-0.46-rpi.tar.gz"

runme() {
    if [ ! -f "$INSTALL_DIR/openmw/openmw" ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run..."
    cd "$INSTALL_DIR"/openmw && ./openmw.sh
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
Exec=${INSTALL_DIR}/openmw/openmw.sh
Path=${INSTALL_DIR}/openmw/
Icon=${INSTALL_DIR}/openmw/icon.png
Type=Application
Comment=The Elder Scrolls III: Morrowind is an open-world RPG developed by Bethesda Game Studios and published by Bethesda Softworks.
Categories=Game;
EOF
    fi
}

post_install() {
    local OPENMW_CONFIG
    OPENMW_CONFIG="$INSTALL_DIR/openmw/resources/openmw-config.tar.gz"

    if [[ $(get_keyboard_layout) == "es" ]]; then
        echo
        echo "Detected Latin/Spanish user. Applying translation..."
        download_and_extract "$ES_TRANSLATION_URL" "$INSTALL_DIR/openmw"
        OPENMW_CONFIG="$INSTALL_DIR/openmw/Morrowind/openmw-es-settings.tar.gz"
    fi
    [[ ! -d ~/.config/openmw ]] && tar -xf "$OPENMW_CONFIG" -C ~/.config
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    if exists_magic_file; then
        BINARY_URL=$(extract_path_from_file "$VAR_DATA_NAME")
        message_magic_air_copy "$VAR_DATA_NAME"
    fi

    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    generate_icon
    post_install
    echo -e "\nDone!. You can play typing $INSTALL_DIR/openmw/openmw.sh or opening the Menu > Games > OpenMW.\n"
    exit_message
}

install_script_message
echo "
OpenMW 0.46.0 for Raspberry Pi
==============================

 · Thanks to Salva (Pi Labs) & ptitSeb.
 · Install path: $INSTALL_DIR/openmw
 · REMEMBER YOU NEED A LEGAL COPY OF THE GAME and copy neccessary files inside $INSTALL_DIR/openmw
 · More info at https://openmw.org/
 · Wanna the best for this game?. Follow the Morrowind graphics guide at https://wiki.nexusmods.com/index.php/Morrowind_graphics_guide
 · This game uses an embedded Mesa driver inside game's directory with some library dependencies.
 · PDF Guide and manual on $INSTALL_DIR/openmw/docs.
"
read -p "Press [ENTER] to continue..."

install
