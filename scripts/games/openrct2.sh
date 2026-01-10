#!/bin/bash
#
# Description : OpenRCT2
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 2.0.0 (10/Jan/26)
# Tested      : Raspberry Pi 5
#
# shellcheck disable=SC1091
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly VERSION="0.4.29"
readonly PACKAGES=(libbenchmark1.9.1 libduktape207 libzip5)
readonly PACKAGES_DEV=(cmake libsdl2-dev libicu-dev gcc pkg-config libspeex-dev libspeexdsp-dev libcurl4-openssl-dev libcrypto++-dev libfontconfig1-dev libfreetype6-dev libpng-dev libssl-dev libzip-dev build-essential make nlohmann-json3-dev libbenchmark-dev libflac-dev libvorbis-dev libzstd-dev)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/openrct2-rpi.tar.gz"
readonly BINARY_64_BITS_URL="https://raw.githubusercontent.com/jmcerrejon/pikiss-bin/refs/heads/main/games/openrct2_0.4.29-rpi-aarch64.deb"
readonly SOURCE_CODE_URL="https://github.com/OpenRCT2/OpenRCT2"
readonly VAR_DATA_NAME="RCT2"
DATA_URL="https://archive.org/download/RollerCoasterTycoon2TTPEN/RollerCoasterTycoon2TTP_EN.zip"

runme() {
    if [[ ! -f /usr/bin/openrct2 ]]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run..."
    openrct2
    exit_message
}

uninstall() {
    read -p "Do you want to uninstall OpenRCT2 (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR"/openrct2 ~/.config/OpenRCT2 ~/.local/share/applications/openrct2.desktop
        sudo apt-get -y remove openrct2
        if [[ -e "$INSTALL_DIR"/openrct2 ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/openrct2 ]] || [[ -e /usr/bin/openrct2 ]]; then
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
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    git clone "$SOURCE_CODE_URL" OpenRCT2 && cd "$_" || exit 1
    mkdir -p build && cd "$_" || exit 1
    cmake ..
    echo -e "\nCompiling. Estimated time on RPi 5: ~8 minutes...\n"
    make_with_all_cores
    exit_message
}

install() {
    echo -e "\n\nInstalling OpenRCT2, please wait..."
    install_packages_if_missing "${PACKAGES[@]}"

    if is_userspace_64_bits; then
        wget -q --show-progress "$BINARY_64_BITS_URL" -O /tmp/openrct2.deb
        sudo dpkg -i /tmp/openrct2.deb
    else
        download_and_extract "$BINARY_URL" "$INSTALL_DIR"
        generate_icon
    fi

    download_and_extract "$DATA_URL" "$INSTALL_DIR"/openrct2/DATA

    echo -e "\nDone!. You can play typing $INSTALL_DIR/openrct2/openrct2.sh or opening the Menu > Games > Openrct2.\n"
    runme
}

install_script_message
echo "
OpenRCT2
========

· Open Source re-implementation of RollerCoaster Tycoon 2.
· Version: $VERSION for aarch64.
· This script installs the demo version by default with no limits in the directory: $INSTALL_DIR/openrct2/DATA
"

read -p "Press [Enter] to continue or [CTRL]+C to abort..."

install
