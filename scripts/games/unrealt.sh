#!/bin/bash
#
# Description : Unreal Tournament 99 (GOTY)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (2/Apr/24)
# Tested      : Raspberry Pi 5
#
# HELP	      : https://www.oldunreal.com
# TODO	      : Add High textures. https://sites.google.com/view/unrealhdtextures/download-hd-textures?authuser=0
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games/ut99"
readonly PACKAGES=(libenet7)
readonly GAME_URL="https://github.com/OldUnreal/UnrealTournamentPatches/releases/download/v469d/OldUnreal-UTPatch469d-Linux-arm64.tar.bz2"
readonly SOURCE_CODE_URL="https://github.com/OldUnreal/UnrealTournamentPatches?tab=readme-ov-file#linux-installation"
readonly VAR_DATA_NAME="UT99"

uninstall() {
    echo
    read -p "Do you want to uninstall Unreal Tournament 99 (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf ~/.local/share/applications/ut99.desktop "$INSTALL_DIR" ~/.utpg
        if [[ -e $INSTALL_DIR ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -e $INSTALL_DIR ]]; then
    echo "Warning!: Unreal Tournament 99 already installed."
    uninstall
fi

generate_icon() {
    local ICON_URL="https://avatars.githubusercontent.com/u/55911444?s=64"
    echo -e "\n\nGenerating icon..."
    wget "$ICON_URL" -O "$INSTALL_DIR/icon.jpg" &>/dev/null
    if [[ ! -e ~/.local/share/applications/ut99.desktop ]]; then
        cat <<EOF >~/.local/share/applications/ut99.desktop
[Desktop Entry]
Name=Unreal Tournament 99
Exec=${INSTALL_DIR}/SystemARM64/ut-bin
Icon=${INSTALL_DIR}/icon.jpg
Path=${INSTALL_DIR}
Type=Application
Comment=Unreal Tournament 99 is a first-person shooter video game developed by Epic Games and Digital Extremes.
Categories=Game;ActionGame;
EOF
    fi
}

install_game() {
    echo -e "\nInstalling Unreal Tournament..."
    install_packages_if_missing "${PACKAGES[@]}"
    mkdir -p "$INSTALL_DIR" && cd "$_" || exit 1
    download_and_extract "$GAME_URL" "$INSTALL_DIR"
}

download_data_files() {
    DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME")
    message_magic_air_copy "$VAR_DATA_NAME"
    download_and_extract "$DATA_URL" "$INSTALL_DIR"
}

install() {
    install_game
    echo -e "\nInstalling Unreal Tournament data..."
    cd "$INSTALL_DIR" || exit 1
    mkdir -p ./cache ./profiles ./replays ./times
    generate_icon
    download_data_files
    echo -e "\nDone!. Go to Menu Games > Unreal Tournament 99 or cd into $INSTALL_DIR/SystemARM64/ and type: ./ut-bin"
    exit_message
}

install_script_message
echo "
Unreal Tournament 99
====================

· The game will be installed on $INSTALL_DIR.
· You need the original game files to play. Check the official site at $SOURCE_CODE_URL
· OldUnreal's latest OpenGL-based 3D renderer (XOpenGLDrv). Vulkan is not supported.
· SDL2-based window management.
"

install
