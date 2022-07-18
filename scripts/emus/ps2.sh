#!/bin/bash
#
# Description : AetherSX2  A Playstation 2 Emulator for ARM devices.
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.1 (18/Jul/22)
# Compatible  : Raspberry Pi 4 (tested)
# Repository  : https://www.aethersx2.com/archive/?dir=desktop/linux
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libopengl0)
readonly GAME_DATA_URL="https://archive.org/download/magic-castle-2021-01-feb/Magic_Castle_2021_01_feb.chd"
readonly BIOS_URL="https://downloads.retrostic.com/bioses/ps2_bios.zip"
readonly FILENAME="AetherSX2-v1.0-2455.AppImage"
readonly BINARY_URL="https://www.aethersx2.com/archive/desktop/linux/$FILENAME"

runme() {
    if [ ! -f "$INSTALL_DIR/aethersx2/aethersx2" ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run..."
    cd "$INSTALL_DIR"/aethersx2 && ./aethersx2
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/aethersx2 ~/.local/share/applications/aethersx2.desktop ~/.local/config/aethersx2
}

uninstall() {
    read -p "Do you want to uninstall AetherSX2 (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/aethersx2 ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/aethersx2 ]]; then
    echo -e "AetherSX2 already installed.\n"
    uninstall
fi

generate_icon() {
    local ICON_URL
    ICON_URL="https://www.aethersx2.com/img/logo.png"

    echo -e "\nGenerating icon..."
    download_file "$ICON_URL" "$INSTALL_DIR"/aethersx2/
    if [[ ! -e ~/.local/share/applications/aethersx2.desktop ]]; then
        cat <<EOF >~/.local/share/applications/aethersx2.desktop
[Desktop Entry]
Name=AetherSX2
Version=1.0
Type=Application
Comment=AetherSX2 is an emulator of the PS Two console
Exec=${INSTALL_DIR}/aethersx2/${FILENAME}
Icon=${INSTALL_DIR}/aethersx2/logo.png
Path=${INSTALL_DIR}/aethersx2/
Terminal=false
Categories=Game;
EOF
    fi
}

download_bios() {
    echo -e "\nDownloading BIOS files..."
    download_and_extract "$BIOS_URL" "$HOME/.config/aethersx2/bios"
}

download_data() {
    echo
    read -p "Do you want to download a Homebrew game called Magic Castle (~140Mb)? (Due to the server where is hosted, It can take a while) (Y/n) " response
    if [[ $response =~ [Nn] ]]; then
        return
    fi
    echo -e "\nDownloading Magic Castle by Kaiga...\nMore info at http://netyaroze-europe.com/Media/Magic-Castle"
    download_file "$GAME_DATA_URL" "$INSTALL_DIR"/aethersx2/games
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    download_file "$BINARY_URL" "$INSTALL_DIR/aethersx2"
    chmod +x "$INSTALL_DIR/aethersx2/$FILENAME"
    # download_bios
    generate_icon
    # download_data
    echo -e "\n\nDone!. You can play typing $INSTALL_DIR/aethersx2/aethersx2 or opening the Menu > Games > AetherSX2.\n"
    runme
}

install_script_message
echo "
AetherSX2 for Raspberry Pi
============================

 · A Playstation 2 Emulator for ARM devices (Very alpha stage).
 · It requires Vulkan to be installed.
 · BIOS & homebrew game included.
 · Install path: $INSTALL_DIR/aethersx2 | Games path: $INSTALL_DIR/aethersx2/games
 · Keys: D-Pad: W/A/S/D | Triangle/Square/Circle/Cross: Numpad8/Numpad4/Numpad6/Numpad2 | L1/R1: Q/E | L2/R2: 1/3 | Start: Enter | Select: Backspace
 · More Info: https://www.aethersx2.com/
"
read -p "Press [ENTER] to continue..."
echo -e "\nInstalling..."
install
