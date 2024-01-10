#!/bin/bash
#
# Description : Snes9X and BSNes
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.2.0 (10/Jan/24)
# Tested      : Raspberry Pi 5
# Repository  : https://github.com/snes9xgit/snes9x
#             : https://github.com/bsnes-emu/bsnes | Try https://github.com/vanfanel/bsnes-mercury
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly GAME_URL="https://archive.org/download/new-super-mario-land/New_Super_Mario_Land_J_V1.2.sfc"
readonly PACKAGES_SNES9X=(libportaudio2 libminizip1)
readonly PACKAGES_BSNES=(libgtksourceview2.0-0 libao4 libopenal1)
readonly PACKAGES_DEV_SNES9X=(libgtkmm-3.0-dev libsdl2-dev libx11-dev libepoxy-dev cmake libpulse-dev libasound2-dev libportaudio2 libwayland-dev libpng-dev libminizip-dev zlib1g-dev portaudio19-dev gettext)
readonly PACKAGES_DEV_BSNES=(qtbase5-dev qtbase5-dev-tools libxv-dev  libao-dev libopenal-dev g++ libdbus-1-dev libcairo2-dev libgtk-3-dev libudev-dev)
BINARY_SNES9X_URL="https://misapuntesde.com/res/snes9x_1-60.tar.gz"
BINARY_BSNES_URL="https://misapuntesde.com/rpi_share/bsnes-111.8-rpi.tar.gz"
readonly BINARY_SNES9X_64_URL="https://misapuntesde.com/rpi_share/snes9x_1-62.3-aarch64.tar.gz"
readonly BINARY_BSNES_64_URL="https://misapuntesde.com/rpi_share/bsnes_115-aarch64.tar.gz"

INPUT=/tmp/snes.$$

runme() {
    echo
    read -p "Do you want to play New Super Mario Land now? [y/n] " option
    case "$option" in
        y*) "$INSTALL_DIR/$1/$1" "$INSTALL_DIR/$1/roms/new_super_mario_land.sfc" -fullscreen -maxaspect;;
    esac
}

uninstall_snes9x() {
    if [[ ! -d "$INSTALL_DIR"/snes9x ]]; then
        return 0
    fi
    read -p "Snes9X already installed. Do you want to uninstall Snes9X (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR"/snes9x ~/.local/share/applications/snes9x.desktop ~/.snes9x
        if [[ -e "$INSTALL_DIR"/snes9x ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

uninstall_bsnes() {
    if [[ ! -d "$INSTALL_DIR"/bsnes ]]; then
        return 0
    fi
    read -p "Bsnes already installed. Do you want to uninstall Bsnes (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR"/bsnes ~/.local/share/applications/bsnes.desktop ~/.config/bsnes
        if [[ -e "$INSTALL_DIR"/bsnes ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

install_data() {
    local DESTINATION_DIR
    DESTINATION_DIR="$INSTALL_DIR/$1/roms"

    mkdir -p "$DESTINATION_DIR"
    echo -e "\nInstalling game New Super Mario Land on $INSTALL_DIR\n"
    wget -q -O "$DESTINATION_DIR/new_super_mario_land.sfc" "$GAME_URL"
}

compile_snes9x() {
    echo -e "\nInstalling dependencies...\n"
    install_packages_if_missing "${PACKAGES_DEV_SNES9X[@]}"
    echo -e "\nCompiling. Estimated time usging Pi 5: ~6minutes...\n"
    mkdir -p "$HOME/sc" && cd "$_" || return 0
    git clone https://github.com/snes9xgit/snes9x.git snes9x && cd "$_" || return 0
    git submodule update --init --recursive
    cd gtk || return 0
    cmake -G Ninja -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=RelWithDebInfo -DGETTEXT_MSGFMT_EXECUTABLE=/usr/bin/msgfmt -S . -B build
    cd build || return 0
    time ninja -C . -j"$(nproc)"
    sudo ninja install
}

compile_bsnes() {
    echo -e "\nInstalling dependencies...\n"
    install_packages_if_missing "${PACKAGES_DEV_BSNES[@]}"
    echo -e "\nCompiling. Estimated time usging Pi 5: ~6minutes...\n"
    mkdir -p "$HOME/sc" && cd "$_" || return 0
    download_and_extract https://github.com/bsnes-emu/bsnes/archive/refs/tags/nightly.zip "$HOME/sc"
    unzip nightly.zip && cd bsnes-nightly || return 0
    cd bsnes || return 0
    make_with_all_cores
    if [[ -e "$HOME/sc/bsnes-nightly/bsnes/out/bsnes" ]]; then
        echo -e "\nDone!."
    fi
}

install_snes9x() {
    uninstall_snes9x
    install_packages_if_missing "${PACKAGES_SNES9X[@]}"
    mkdir -p "$INSTALL_DIR/snes9x" && cd "$_" || return
    if is_kernel_64_bits; then
        BINARY_SNES9X_URL=$BINARY_SNES9X_64_URL
    fi
    download_and_extract "$BINARY_SNES9X_URL" "$INSTALL_DIR"
    install_data snes9x
    echo -e "Done!. To play go to install path, copy any rom to /roms directory and type: ./snes9x <rom name>\nFor example, ./snes9x roms/new_super_mario_land.sfc -fullscreen -maxaspect"
    runme snes9x
}

generate_icon_bsnes() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/bsnes.desktop ]]; then
        cat <<EOF >~/.local/share/applications/bsnes.desktop
[Desktop Entry]
Name=BSnes
Type=Application
Comment=SuperNES emulator that focuses on performance, features, and ease of use
Exec=${INSTALL_DIR}/bsnes/bsnes
Icon=${INSTALL_DIR}/bsnes/icon.png
Path=${INSTALL_DIR}/bsnes/
Terminal=false
Categories=Game;
EOF
    fi
}

post_install_bsnes() {
    if [[ ! -d ~/.config/bsnes ]]; then
        mkdir -p ~/.config/bsnes
        cp -rf "$INSTALL_DIR/bsnes/settings.bml" ~/.config/bsnes
    fi
}

install_bsnes() {
    uninstall_bsnes
    install_packages_if_missing "${PACKAGES_BSNES[@]}"
    if is_kernel_64_bits; then
        BINARY_BSNES_URL=$BINARY_BSNES_64_URL
    fi
    download_and_extract "$BINARY_BSNES_URL" "$INSTALL_DIR"
    post_install_bsnes
    generate_icon_bsnes
    install_data bsnes
    echo -e "KEYS: Left Shift, ENTER, Arrows, Q, W, A, S, Z, X & F12=Full Screen.\n\nDone!. You can play typing $INSTALL_DIR/bsnes/bsnes or opening the Menu > Games > BSnes"
    runme bsnes
}

menu() {
    while true; do
        dialog --clear \
            --title "[ SuperNES for Raspberry Pi ]" \
            --menu "Choose the emulator:" 11 100 3 \
            BSnes "It focuses on performance, features, and ease of use with GUI" \
            Snes9x "It basically allows you to play most games designed for the SNES for Terminal" \
            Exit "Back to main menu" 2>"${INPUT}"

        menuitem=$(<"${INPUT}")

        case $menuitem in
        Snes9x) clear && install_snes9x && return 0 ;;
        BSnes) clear && install_bsnes && return 0 ;;
        Exit) exit 0 ;;
        esac
    done
}

menu