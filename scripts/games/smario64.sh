#!/bin/bash
#
# Description : Super Mario 64 Plus
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.4.1 (25/Jun/23)
# Compatible  : Raspberry Pi 4 (tested)
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libusb-1.0-0)
readonly PACKAGES_DEV=(libaudiofile-dev libglew-dev libsdl2-dev libusb-1.0-0-dev)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/sm64ex-rpi.tar.gz"
readonly BINARY_64_BITS_URL="https://misapuntesde.com/rpi_share/sm64plus-aarch64-rpi.tar.gz"
readonly ROM_URL="https://e.pcloud.link/publink/show?code=XZSjXfZpiOInSiqy97Lpjs79MDzxhVvs6Vy"
readonly SOURCE_CODE_URL="https://github.com/MorsGames/sm64plus"

runme() {
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/sm64 && ./sm64.us
    exit_message
}

remove_files() {
    sudo rm -rf "$INSTALL_DIR"/sm64 ~/.local/share/sm64pc ~/.local/share/applications/sm64plus.desktop
}

uninstall() {
    read -p "Do you want to uninstall Super Mario 64 Plus (y/N)? " response
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
    echo -e "Super Mario 64 Plus already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\n\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/sm64plus.desktop ]]; then
        cat <<EOF >~/.local/share/applications/sm64plus.desktop
[Desktop Entry]
Name=Super Mario 64 Plus
Exec=${INSTALL_DIR}/sm64/sm64.us
Icon=${INSTALL_DIR}/sm64/star.ico
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
    download_file "$ROM_URL" .
    echo -e "\n\nCompiling... Estimated time on RPi 4: < 5 min.\n"
    make_with_all_cores TARGET_RPI=1 BETTERCAMERA=1 NODRAWINGDISTANCE=1 TEXTURE_FIX=1 EXT_OPTIONS_MENU=1 EXTERNAL_DATA=1
    cd build/us_pc || exit 1
    echo -e "\n\nDone! ALT+ENTER full-screen | SPACE Select | WSAD for move | Arrows for camera, [KL,.] for actions.\n"
    read -p "Press [ENTER] to run the game."
    ./sm64.us.f3dex2e.arm
}

install() {
    local BINARY_URL_INSTALL=$BINARY_URL
    echo -e "\n\nInstalling, please wait..."

    if is_userspace_64_bits; then
        BINARY_URL_INSTALL=$BINARY_64_BITS_URL
    fi

    download_and_extract "$BINARY_URL_INSTALL" "$INSTALL_DIR"
    generate_icon
    echo -e "\n\nDone!. You can play typing $INSTALL_DIR/sm64/sm64.us or opening the Menu > Games > Super Mario 64.\n"
    echo -e "ALT+ENTER full-screen | SPACE Select | WSAD for move | Arrows for camera, [KL,.] for actions.\n"
    runme
}

install_script_message
echo "
Super Mario 64 Plus
===================

· Based on the work of MorsGames, this is a port of Super Mario 64 for the Raspberry Pi, along with a number of optimizations.
· More responsive controls, improved camera, extended moveset, the ability to continue the level after getting a star, optional extra modes, 60fps support via interpolation, various bug fixes.
· Look at the file settings.ini for set some parameters & hacks.
· KEYS: ALT+ENTER full-screen | SPACE Select | WSAD for move | Mouse or arrows for camera, [KL,.] for actions.
"

install
