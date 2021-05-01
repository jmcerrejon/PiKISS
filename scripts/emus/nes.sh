#!/bin/bash
#
# Description : Nestopia (NES emulator)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (Apr/21)
# Compatible  : Raspberry Pi 2-4
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly BINARY_URL="https://misapuntesde.com/rpi_share/nestopia_v1.51.0_rpi.tar.gz"
readonly PACKAGES=(build-essential autoconf autoconf-archive automake autotools-dev libfltk1.3-dev libsdl2-dev libarchive-dev zlib1g-dev)
readonly PACKAGES_DEV=(build-essential autoconf autoconf-archive automake autotools-dev libfltk1.3-dev libsdl2-dev libarchive-dev zlib1g-dev)
readonly GAME_URL="https://misapuntesde.com/res/Spacegulls-1.1.nes"
readonly SOURCE_CODE_URL="https://github.com/0ldsk00l/nestopia"

runme() {
    echo
    read -p "Do you want to play a cool NES game now? [y/n] " option
    case "$option" in
    y*) "$INSTALL_DIR/nestopia/nestopia" "$INSTALL_DIR/nestopia/roms/Spacegulls-1.1.nes" ;;
    esac
}

uninstall() {
    if [[ ! -d "$INSTALL_DIR"/nestopia ]]; then
        return 0
    fi
    read -p "Nestopia already installed. Do you want to uninstall (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR"/nestopia ~/.local/share/applications/nestopia.desktop ~/.nestopia
        if [[ -e "$INSTALL_DIR"/nestopia ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

post_install() {
    local DESTINATION_DIR
    DESTINATION_DIR="$INSTALL_DIR/nestopia/roms"

    mkdir -p "$DESTINATION_DIR"
    echo -e "\nDownloading game, please wait..."
    download_file "$GAME_URL" "$DESTINATION_DIR"
}

generate_icon() {
    echo -e "\nGenerating icon...\n"
    if [[ ! -e ~/.local/share/applications/nestopia.desktop ]]; then
        cat <<EOF >~/.local/share/applications/nestopia.desktop
[Desktop Entry]
Name=Nestopia UE
Type=Application
Comment=Accurate NES emulator
Exec=${INSTALL_DIR}/nestopia/nestopia
Icon=${INSTALL_DIR}/nestopia/icons/32/nestopia.png
Path=${INSTALL_DIR}/nestopia/
Terminal=false
Categories=Game;Emulator;
EOF
    fi
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    echo
    git clone "$SOURCE_CODE_URL" blood && cd "$_" || exit 1
    autoreconf -vif
    ./configure
    echo -e "\n\nCompiling... Estimated time on RPi 4: <5 min.\n"
    make_with_all_cores
    echo -e "\nDone!."
    exit_message
}

install() {
    uninstall
    install_script_message
    echo "
Nestopia UE
===========

 · Version 1.51.0
 · Install path: $INSTALL_DIR/nestopia
 · Homebrew game included: SpaceGulls is a NES game from the 2020 NESdev Competition. + Info: https://morphcatgames.itch.io/spacegulls
 · Keys: Arrows: Move | Z: A | X: B | Shift: Select | ENTER: Start | F12: Reset | F5/F6: Quick Save | F7/F8: Quick Load | F: Full Screen
"
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    post_install
    generate_icon
    echo -e "Done!. You can play typing $INSTALL_DIR/nestopia/nestopia or opening the Menu > Games > Nestopia UE"
    runme
}

install
