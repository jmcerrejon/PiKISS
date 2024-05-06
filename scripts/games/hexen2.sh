#!/bin/bash
#
# Description : Hexen ][ using fteqw engine for Raspberry Pi
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (07/May/24)
# Tested      : Raspberry Pi 5
#
# Help        : https://github.com/sezero/uhexen2 (Another port )
#             : https://github.com/tpo1990/Hexen2-RPI/blob/master/Hexen2-Install-Desktop.sh
# shellcheck source=../helper.sh
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly SOURCE_CODE_URL="https://github.com/fte-team/fteqw"
readonly BINARY_URL="https://misapuntesde.com/rpi_share/hexen2-aarch64.tar.gz"
readonly VAR_DATA_NAME="HEXEN_2"
DATA_URL="https://misapuntesde.com/rpi_share/h2-demo.tar.gz"

runme() {
    if [ ! -f "$INSTALL_DIR"/hexen2/run.sh ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/hexen2 && ./run.sh
    exit_message
}

uninstall() {
    read -p "Do you want to uninstall it (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR"/hexen2 ~/.local/share/applications/hexen2.desktop
        if [[ -e $INSTALL_DIR/hexen2 ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi

        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi

    exit_message
}

if [[ -d $INSTALL_DIR/hexen2 ]]; then
    echo -e "Hexen 2 already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/hexen2.desktop ]]; then
        cat <<EOF >~/.local/share/applications/hexen2.desktop
[Desktop Entry]
Name=Hexen 2
Exec=${INSTALL_DIR}/hexen2/run.sh
Icon=${INSTALL_DIR}/hexen2/icon.png
Path=${INSTALL_DIR}/hexen2/
Type=Application
Comment=Hexen II is a dark fantasy 1st shooter and RPG developed by Raven Software and published by Id Software in 1997. It is the third game in the Heretic/Hexen series and the epic conclusion to the Serpent Riders trilogy.
Categories=Game;ActionGame;
EOF
    fi
}

install_binary() {
    echo -e "\nInstalling binary files..."
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
}

magic_air_copy() {
    if exists_magic_file; then
        DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME")
        message_magic_air_copy "$VAR_DATA_NAME"
    fi
    download_and_extract "$DATA_URL" "$HOME/games/hexen2/games"
}

install() {
    echo -e "\n\nInstalling, please wait...\n"
    mkdir -p "$INSTALL_DIR"
    install_binary
    generate_icon
    magic_air_copy
    echo -e "\nDone!. You can play typing $INSTALL_DIR/hexen2/run.sh or opening the Menu > Games > Hexen 2.\n"
    runme
}

install_script_message
    echo "
Hexen ][ for Raspberry Pi
=========================

 · OpenGL version.
 · If you don't provide game data file inside res/magic-air-copy-pikiss.txt, demo version will be installed.
"

read -p "Press [ENTER] to continue..."

install
