#!/bin/bash
#
# Description : OpenRCT2
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.1 (25/Oct/21)
# Compatible  : Raspberry Pi 4 (tested)
#
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly BINARY_URL="https://misapuntesde.com/rpi_share/openrct2-rpi.tar.gz"
readonly PACKAGES=(libbenchmark1 libduktape203 libzip4)
readonly PACKAGES_DEV=(cmake libsdl2-dev libicu-dev gcc pkg-config libspeex-dev libspeexdsp-dev libcurl4-openssl-dev libcrypto++-dev libfontconfig1-dev libfreetype6-dev libpng-dev libssl-dev libzip-dev build-essential make duktape-dev libbenchmark-dev libzip4)
readonly SOURCE_CODE_URL="https://github.com/OpenRCT2/OpenRCT2"
readonly VAR_DATA_NAME="RCT2"
DATA_URL="https://openrct2.org/files/demo/RollerCoasterTycoon2TTP_EN.zip"

runme() {
    if [[ ! -f $INSTALL_DIR/openrct2/openrct2.sh ]]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run..."
    cd "$INSTALL_DIR"/openrct2 && ./openrct2.sh
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/openrct2 ~/.config/OpenRCT2 ~/.local/share/applications/openrct2.desktop
}

uninstall() {
    read -p "Do you want to uninstall OpenRCT2 (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/openrct2 ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/openrct2 ]]; then
    echo -e "OpenRCT2 already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/openrct2.desktop ]]; then
        cat <<EOF >~/.local/share/applications/openrct2.desktop
[Desktop Entry]
Name=OpenRCT2
Exec=${INSTALL_DIR}/openrct2/openrct2.sh
Icon=${INSTALL_DIR}/openrct2/icons/hicolor/64x64/apps/openrct2.png
Path=${INSTALL_DIR}/openrct2/
Type=Application
Comment=Open Source re-implementation of RollerCoaster Tycoon 2.
Categories=Game;Simulation;
EOF
    fi
}

compile() {
    echo -e "\nInstalling dependencies (if proceed)...\n"
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    wget http://ftp.us.debian.org/debian/pool/main/n/nlohmann-json3/nlohmann-json3-dev_3.7.0-2~bpo10+1_all.deb && sudo dpkg -i nlohmann-json3-dev_3.7.0-2~bpo10+1_all.deb && rm nlohmann-json3-dev_3.7.0-2~bpo10+1_all.deb
    cd "$INSTALL_DIR" || exit 1
    git clone "$SOURCE_CODE_URL" OpenRCT2 && cd "$_" || exit 1
    mkdir -p build && cd "$_" || exit 1
    cmake ..
    echo -e "\nCompiling. Estimated time: ~15 minutes, so be patience...\n"
    make_with_all_cores
    echo -e "\nDone. Copy the game data files and run" || exit 0
}

install() {
    echo -e "\n\nInstalling OpenRCT2, please wait..."
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    if exists_magic_file; then
        DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME")
        message_magic_air_copy "$DATA_URL"
    fi

    echo -e "\nSearching game data files,..."
    download_and_extract "$DATA_URL" "$INSTALL_DIR"/openrct2/DATA
    generate_icon
    echo -e "\nDone!. You can play typing $INSTALL_DIR/openrct2/openrct2.sh or opening the Menu > Games > Openrct2.\n"
    runme
}

install_script_message
echo "
OpenRCT2
========

 · Optimized for Raspberry Pi 4.
 · Total space occupied: 1.6 Gb.
 · Install the demo version by default with no limits.
 · Install path: $INSTALL_DIR/openrct2
"

read -p "Press [Enter] to continue or [CTRL]+C to abort..."

install
