#!/bin/bash
#
# Description : Super Mario 64 EX
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.2.2 (14/Jan/22)
# Compatible  : Raspberry Pi 4 (tested)
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES_DEV=(libaudiofile-dev libglew-dev libsdl2-dev)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/sm64ex-rpi.tar.gz"
readonly ROM_URL="https://s2roms.cc/s3roms/Nintendo%2064/P-T/Super%20Mario%2064%20%28U%29%20%5B%21%5D.zip"
readonly SOURCE_CODE_URL="https://github.com/foxhound311/sm64ex"

runme() {
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/sm64 && ./sm64
    read -p "Press ENTER to go back to main menu"
    exit
}

remove_files() {
    sudo rm -rf "$INSTALL_DIR"/sm64 ~/.local/share/sm64pc ~/.local/share/applications/sm64.desktop
}

uninstall() {
    read -p "Do you want to uninstall Super Mario 64 port EX (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/sm64 ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/sm64 ]]; then
    echo -e "Super Mario 64 port EX already installed.\n"
    uninstall
    exit 1
fi

generate_icon() {
    echo -e "\n\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/sm64.desktop ]]; then
        cat <<EOF >~/.local/share/applications/sm64.desktop
[Desktop Entry]
Name=Super Mario 64 port EX
Exec=${INSTALL_DIR}/sm64/sm64
Icon=${INSTALL_DIR}/sm64/icon.jpg
Path=${INSTALL_DIR}/sm64
Type=Application
Comment=Super Mario 64 is a 1996 platform video game for the Nintendo 64 and the first in the Super Mario series to feature 3D gameplay.
Categories=Game;ActionGame;
EOF
    fi
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    [[ -d $HOME/sc/mario64 ]] && rm -rf "$HOME/sc/mario64"
    git clone "$SOURCE_CODE_URL" mario64 && cd "$_" || exit 1
    wget -O ./sm64.zip --no-check-certificate "$ROM_URL"
    unzip sm64.zip && rm sm64.zip
    mv Super\ Mario\ 64\ \(U\)\ \[\!\].z64 baserom.us.z64
    echo -e "\n\nCompiling... Estimated time on RPi 4: < 5 min.\n"
    make_with_all_cores TARGET_RPI=1 BETTERCAMERA=1 NODRAWINGDISTANCE=1 TEXTURE_FIX=1 EXT_OPTIONS_MENU=1 EXTERNAL_DATA=1
    cd build/us_pc || exit 1
    echo -e "\n\nDone! ALT+ENTER full-screen | SPACE Select | WSAD for move | Arrows for camera, [KL,.] for actions.\n"
    read -p "Press [ENTER] to run the game."
    ./sm64.us.f3dex2e.arm
}

install() {
    echo -e "\n\nInstalling, please wait..."
    if [[ $(validate_url "$BINARY_URL") != "true" ]]; then
        read -p "Sorry, the game is not available here: $BINARY_URL. Try to compile."
        exit
    fi
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    generate_icon
    echo -e "\n\nDone!. You can play typing $INSTALL_DIR/sm64/sm64 or opening the Menu > Games > Super Mario 64.\n"
    echo -e "ALT+ENTER full-screen | SPACE Select | WSAD for move | Arrows for camera, [KL,.] for actions.\n"
}

install_script_message
echo "
Super Mario 64 port EX for Raspberry Pi
=======================================

 · Thanks @foxhound311.
 · HD Mario, HD bowser and you ride a Mario kart instead of a turtle when you grab a star.
"
read -p "Press [Enter] to continue..."

install
runme
