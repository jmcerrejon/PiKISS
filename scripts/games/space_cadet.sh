#!/bin/bash
#
# Description: 3D Pinball for Windows - Space Cadet.
# Author     : Jose Cerrejon Gonzalez (ulysess@gmail.com)
# Version    : 1.0.1 (04/8/2025)
# Tested     : Raspberry Pi 5
#
# shellcheck source=../helper.sh
# shellcheck disable=SC1094
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh..." && exit 1; }
clear

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libsdl2-dev libsdl2-mixer-dev)
readonly PACKAGES_DEV=(cmake)
readonly GITHUB_REPO_URL="https://github.com/k4zmu2a/SpaceCadetPinball"
readonly BINARY_URL="https://misapuntesde.com/rpi_share/space-cabinet-rpi-aarch64.tar.gz"
readonly ASSETS_FILE_NAME="3d_pinball_for_windows_space_cadet.exe"
readonly ASSETS_URL="https://misapuntesde.com/rpi_share/${ASSETS_FILE_NAME}"
readonly SOURCE_CODE_DIR_NAME="SpaceCadetPinball"

runme() {
    if [ ! -d "$INSTALL_DIR/SpaceCadetPinball" ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR/SpaceCadetPinball" && ./SpaceCadetPinball
    exit_message
}

uninstall() {
    read -p "Do you want to uninstall Space Cadet Pinball (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR/SpaceCadetPinball" "$HOME/.local/share/applications/spacecadet.desktop" "$HOME/.local/share/SpaceCadetPinball"
        if [[ -e "$INSTALL_DIR/SpaceCadetPinball" ]]; then
            echo -e "I hate when this happens. I could not remove the directory, Try to remove it manually.\n"
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
}

if [[ -d $INSTALL_DIR/SpaceCadetPinball ]]; then
    echo -e "Space Cadet Pinball already installed.\n"
    uninstall
    exit 0
fi

generate_icon() {
    echo -e "\nGenerating icon...\n"
    if [[ ! -e "$HOME/.local/share/applications/spacecadet.desktop" ]]; then
        cat <<EOF >"$HOME/.local/share/applications/spacecadet.desktop"
[Desktop Entry]
Name=Space Cadet Pinball
Exec=${INSTALL_DIR}/SpaceCadetPinball/SpaceCadetPinball
Icon=${INSTALL_DIR}/SpaceCadetPinball/logo.png
Type=Application
Comment=3D Pinball for Windows - Space Cadet
Categories=Game;
Path=${INSTALL_DIR}/SpaceCadetPinball/
EOF
    fi
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc"
    cd "$HOME/sc" || exit 1
    git clone "$GITHUB_REPO_URL"
    cd "$SOURCE_CODE_DIR_NAME" || exit 1
    mkdir build && cd build || exit 1
    cmake .. -DCMAKE_BUILD_TYPE=Release
    make_with_all_cores
    echo -e "\nDone!. Compiled binary at $HOME/sc/$SOURCE_CODE_DIR_NAME/build/SpaceCadetPinball"
    exit_message
}

install_assets() {
    echo -e "\nDownloading assets...\n"
    download_file "$ASSETS_URL" "$INSTALL_DIR/SpaceCadetPinball" "$ASSETS_FILE_NAME"
    unzip -q "$INSTALL_DIR/SpaceCadetPinball/$ASSETS_FILE_NAME" -d "$INSTALL_DIR/SpaceCadetPinball"
    rm -rf "${INSTALL_DIR:?}/SpaceCadetPinball/${ASSETS_FILE_NAME:?}"
    echo -e "Assets installed successfully.\n"
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    install_assets
    generate_icon
    echo -e "\nDone!. To play, go to Menu > Games > Space Cadet Pinball or type $INSTALL_DIR/SpaceCadetPinball."
    runme
}

install_script_message
echo "
3D Pinball for Windows - Space Cadet for Raspberry Pi
=====================================================

 · Thanks to k4zmu2a for the reverse-engineered source code.
 · NOTE: The original game assets are required. PiKISS will attempt to download them from an external source.
"
read -p "Press [Enter] to continue..."

install
