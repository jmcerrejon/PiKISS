#!/bin/bash
#
# Description : PPSSPP for Raspberry Pi
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.2.0 (03/Sep/24)
# Tested      : Raspberry Pi 5
#
# shellcheck source=../helper.sh
. ../helper.sh || . ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly VERSION="1.17.1-19410"
readonly PACKAGES_DEV=(cmake libgl1-mesa-dev libsdl2-dev libsdl2-ttf-dev libfontconfig1-dev libvulkan-dev libgl1-mesa-dev libsdl2-dev readonly libsdl2-ttf-dev libfontconfig1-dev libcurl4-openssl-dev)
readonly PPSSPP_SC_URL="https://github.com/hrydgard/ppsspp.git"
readonly BINARY_URL="https://misapuntesde.com/rpi_share/ppsspp_arm_all.tar.gz"
readonly GAME_URL="https://wololo.net/download.php?f=Silveredge.zip"

runme() {
    echo
    read -p "Do you want to play Silveredge now? [y/n] " option
    case "$option" in
    y*) "$INSTALL_DIR"/ppsspp/ppssppsdl "$INSTALL_DIR"/ppsspp/roms/Silveredge/EBOOT.PBP ;;
    esac
    clear
    exit_message
}

uninstall() {
    read -p "Do you want to uninstall PPSSPP (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR"/ppsspp ~/.local/share/applications/ppsspp.desktop ~/.config/ppsspp
        if [[ -e "$INSTALL_DIR"/ppsspp ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    playNow
}

if [[ -d "$INSTALL_DIR"/ppsspp ]]; then
    echo -e "PPSSPP already installed.\n"
    uninstall
    exit 1
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/ppsspp.desktop ]]; then
        cat <<EOF >~/.local/share/applications/ppsspp.desktop
[Desktop Entry]
Name=PPSSPP
Exec=${INSTALL_DIR}/ppsspp/run.sh
Icon=${INSTALL_DIR}/ppsspp/assets/icon_regular_72.png
Type=Application
Comment=PPSSPP can run your PSP games on your RPi in full HD resolution
Categories=Game;ActionGame;
EOF
    fi
}

downloadROM() {
    echo -e "\nInstalling game Silveredge on $INSTALL_DIR/ppsspp/roms\n"
    mkdir -p "$INSTALL_DIR"/ppsspp/roms/ && cd "$_" || exit 1
    wget -qO- -O "$INSTALL_DIR"/ppsspp/roms/silveredge.zip "$GAME_URL"
    unzip "$INSTALL_DIR"/ppsspp/roms/silveredge.zip && rm "$INSTALL_DIR"/ppsspp/roms/silveredge.zip
}

install() {
    echo -e "Installing, please wait...\n"
    mkdir -p "$INSTALL_DIR" && cd "$_" || exit 1
    wget -qO- -O "$INSTALL_DIR"/tmp.tar.gz "$BINARY_URL" && tar -xzf "$INSTALL_DIR"/tmp.tar.gz && rm "$INSTALL_DIR"/tmp.tar.gz "$INSTALL_DIR"/._ppsspp
    generate_icon
    downloadROM
    echo -e "\nDone!. To play go to Menu > Games > PPSSPP or open a Terminal and type: $INSTALL_DIR/ppsspp/ppssppsdl"
    runme
}

compile() {
    mkdir -p ~/sc && cd "$_" || exit 1
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    git clone --recurse-submodules "$PPSSPP_SC_URL" ppsspp && cd "$_" || exit 1
    cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo .
    make_with_all_cores
}

install_script_message
echo "
Install PPSSPP
==============

· Version: $VERSION
· More Info: https://www.ppsspp.org
· Install free Homebrew game Silveredge (Thanks to Andrew Afy).
· Install path: $INSTALL_DIR/ppsspp
"

install
