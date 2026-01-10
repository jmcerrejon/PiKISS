#!/bin/bash
#
# Description : Duckstation - Fast PlayStation 1 emulator for PC and Android
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.0 (25/Jul/25)
# Tested      : Raspberry Pi 5
#
# shellcheck disable=SC2155
# shellcheck disable=SC1094
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games/duckstation"
readonly PACKAGES_DEV=(cmake ninja-build libsdl2-dev libxrandr-dev pkg-config qtbase5-dev qtbase5-private-dev qtbase5-dev-tools qttools5-dev libevdev-dev libwayland-dev libwayland-egl-dev extra-cmake-modules libcurl4-gnutls-dev libgbm-dev libdrm-dev)
readonly API_URL="https://api.github.com/repos/stenzek/duckstation/releases/latest"
readonly GAME_DATA_URL="https://archive.org/download/magic-castle-2021-07-may/Magic_Castle_2021_07_May.zip"
readonly BIOS_URL="https://downloads.retrostic.com/bioses/SCPH1001.zip"
readonly SOURCE_CODE_URL="https://github.com/stenzek/duckstation"

runme() {
    if [ -f "$EXECUTABLE" ]; then
        read -p "Press [ENTER] to run the emulator..."
        cd "$INSTALL_DIR"/bin && ./duckstation-qt
    fi
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR" ~/.local/share/applications/duckstation.desktop ~/.local/share/duckstation
}

uninstall() {
    read -p "Do you want to uninstall Duckstation (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e $INSTALL_DIR ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d $INSTALL_DIR ]]; then
    echo -e "Duckstation already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/duckstation.desktop ]]; then
        cat <<EOF >~/.local/share/applications/duckstation.desktop
[Desktop Entry]
Name=Duckstation
Version=1.0
Type=Application
Comment=PlayStation 1, aka. PSX Emulator
Exec=${EXECUTABLE}
Icon=${INSTALL_DIR}/share/icons/hicolor/512x512/apps/org.duckstation.DuckStation.png
Path=${INSTALL_DIR}/
Terminal=false
Categories=Game;
EOF
    fi
}

download_binaries() {
    local ARCHITECTURE=$(uname -m)
    local BINARY_URL=$(curl -s "$API_URL" | grep "browser_download_url" | grep "$ARCHITECTURE.AppImage" | head -n 1 | cut -d '"' -f 4)

    echo -e "\nDownloading binaries..."
    mkdir -p "$INSTALL_DIR"/duckstation
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
}

download_bios() {
    echo -e "\nDownloading BIOS files..."
    download_and_extract "$BIOS_URL" "$HOME/.local/share/duckstation/bios"
}

download_data() {
    echo
    read -p "Do you want to download a Homebrew game called Magic Castle (~140Mb)? (Due to the server where is hosted, It can take a while) (Y/n) " response
    if [[ $response =~ [Nn] ]]; then
        return
    fi
    echo -e "\nDownloading Magic Castle by Kaiga...\nMore info at http://netyaroze-europe.com/Media/Magic-Castle"
    download_and_extract "$GAME_DATA_URL" "$INSTALL_DIR"/duckstation/isos
}

install() {
    download_binaries
    download_bios
    generate_icon
    download_data
    echo -e "\n\nDone!. You can play typing $INSTALL_DIR/duckstation/run.sh or opening the Menu > Games > Duckstation.\n"
    runme
}

install_script_message
echo "
Duckstation for Raspberry Pi
============================

 · BIOS & homebrew game included.
 · Install path: $INSTALL_DIR/duckstation | Games path: $INSTALL_DIR/duckstation/isos
 · Keys: D-Pad: W/A/S/D | Triangle/Square/Circle/Cross: Numpad8/Numpad4/Numpad6/Numpad2 | L1/R1: Q/E | L2/R2: 1/3 | Start: Enter | Select: Backspace
 · More Info: ${SOURCE_CODE_URL}
"
read -p "Press [ENTER] to continue..."

install
