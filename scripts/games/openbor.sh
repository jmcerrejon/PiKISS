#!/bin/bash
#
# Description : OpenBOR
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 2.0.1 (21/Dec/25)
# Tested      : Raspberry Pi 5
#
# shellcheck source=../helper.sh
. ../helper.sh || . ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libsdl-gfx1.2-5 libpng16-16 libsdl2-gfx-1.0-0 libvorbisidec1)
readonly PACKAGES_DEV=(libsdl2-gfx-dev libvorbisidec-dev libvpx-dev libogg-dev libsdl2-gfx-1.0-0 libvorbisidec1)
readonly BINARY_URL="https://media.githubusercontent.com/media/jmcerrejon/pikiss-bin/refs/heads/main/games/openbor-v4.0-rpi-aarch64.tar.gz
"
readonly SOURCE_CODE_URL="https://github.com/DCurrent/openbor"

runme() {
    if [ ! -f "$INSTALL_DIR"/openbor/openbor ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/openbor && ./openbor
    echo
    exit_message
}

uninstall() {
    read -p "Do you want to uninstall Openbor (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR"/openbor ~/.local/share/applications/openbor.desktop
        if [[ -e "$INSTALL_DIR"/openbor ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/openbor ]]; then
    echo -e "Openbor already installed.\n"
    uninstall
    exit 0
fi

generate_icon() {
    if [[ ! -e ~/.local/share/applications/openbor.desktop ]]; then
        cat <<EOF >~/.local/share/applications/openbor.desktop
[Desktop Entry]
Name=OpenBOR
Exec=${INSTALL_DIR}/openbor/openbor
Icon=${INSTALL_DIR}/openbor/icon.png
Path=${INSTALL_DIR}/openbor/
Type=Application
Comment=OpenBOR is the open source continuation of Beats of Rage, a Streets of Rage tribute game.
Categories=Game;ActionGame;
EOF
    fi
}

install() {
    echo -e "\nInstalling Openbor, please wait..."
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    generate_icon
    echo -e "\nDone!."
    runme
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p ~/sc && cd "$_" || exit
    echo "Cloning and compiling repo..."
    [[ ! -d ~/sc/openbor ]] && git clone "$SOURCE_CODE_URL"
    make clean-all BUILD_PANDORA=1
    patch -p0 -i ./patch/latest_build.diff
    make_with_all_cores BUILD_PANDORA=1 PNDDEV=/usr
    echo -e "\nDone!"
}

install_script_message
echo "
OpenBOR for Raspberry Pi
========================

 · More Info and games: https://www.chronocrash.com/forum/forums/modules.18 ¡ https://itch.io/games/tag-openbor
 · Game included: Dungeons & Dragons by Zvitor https://www.zvitor.com/projeto/cave.html
 · Install path: $INSTALL_DIR/openbor
 · Some keys: F12 - Menu, ESC - Back, ENTER - Start, Arrow keys - Move, A - Attack, S - Jump
"
read -p "Press [ENTER] to continue..."

install
