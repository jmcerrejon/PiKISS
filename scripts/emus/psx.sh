#!/bin/bash
#
# Description : Duckstation - Fast PlayStation 1 emulator for PC and Android
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.5 (21/Jul/22)
# Compatible  : Raspberry Pi 4 (tested)
# Repository  : https://github.com/stenzek/duckstation
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES_DEV=(cmake ninja-build libsdl2-dev libxrandr-dev pkg-config qtbase5-dev qtbase5-private-dev qtbase5-dev-tools qttools5-dev libevdev-dev libwayland-dev libwayland-egl-dev extra-cmake-modules libcurl4-gnutls-dev libgbm-dev libdrm-dev)
readonly GAME_DATA_URL="https://archive.org/download/magic-castle-2021-01-feb/Magic_Castle_2021_01_feb.chd"
readonly BIOS_URL="https://downloads.gamulator.com/bios/SCPH1001.zip"
readonly SOURCE_CODE_URL="https://github.com/stenzek/duckstation"
readonly BINARY_URL_BUSTER="https://misapuntesde.com/rpi_share/duckstation-rpi-buster.tar.gz"
BINARY_URL="https://misapuntesde.com/rpi_share/duckstation-rpi.tar.gz"

runme() {
    if [ ! -f "$INSTALL_DIR/duckstation/run.sh" ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the emulator..."
    cd "$INSTALL_DIR"/duckstation && ./run.sh
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/duckstation ~/.local/share/applications/duckstation.desktop ~/.local/share/duckstation
}

uninstall() {
    read -p "Do you want to uninstall Duckstation (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/duckstation ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/duckstation ]]; then
    echo -e "Duckstation already installed.\n"
    uninstall
fi

generate_icon() {
    local EXECUTABLE="$INSTALL_DIR"/duckstation/run.sh

    if [[ $CODENAME == "buster" ]]; then
        EXECUTABLE="$INSTALL_DIR"/duckstation/duckstation-qt
    fi

    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/duckstation.desktop ]]; then
        cat <<EOF >~/.local/share/applications/duckstation.desktop
[Desktop Entry]
Name=Duckstation
Version=1.0
Type=Application
Comment=PlayStation 1, aka. PSX Emulator
Exec=${EXECUTABLE}
Icon=${INSTALL_DIR}/duckstation/resources/duck.png
Path=${INSTALL_DIR}/duckstation/
Terminal=false
Categories=Game;
EOF
    fi
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    git clone "$SOURCE_CODE_URL" -b dev duckstation && cd "$_" || exit 1
    mkdir -p build && cd "$_" || exit 1
    cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -GNinja -Wno-dev ..
    echo -e "\nCompiling... It takes ~12 minutes on Rpi4\n"
    cd ..
    time ninja -C build -j"$(nproc)"
    echo -e "\nDone!. Get the binary at $HOME/sc/duckstation/build/bin/duckstation-qt."
    exit_message
}

download_binaries() {
    local CODENAME
    CODENAME=$(get_codename)

    echo -e "\nInstalling binary files..."

    if [[ $CODENAME == "buster" ]]; then
        echo -e "\nDetected Buster code name..."
        BINARY_URL="$BINARY_URL_BUSTER"
    fi

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
    download_file "$GAME_DATA_URL" "$INSTALL_DIR"/duckstation/isos
}

install() {
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
    echo -e "\nInstalling..."
    download_binaries
    download_bios
    generate_icon
    download_data
    echo -e "\n\nDone!. You can play typing $INSTALL_DIR/duckstation/run.sh or opening the Menu > Games > Duckstation.\n"
    runme
}

install
