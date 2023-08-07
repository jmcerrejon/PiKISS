#!/bin/bash
#
# Description : OpenBOR
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.4.8 (07/Aug/23)
# Compatible  : Raspberry Pi 4 (tested)
# Repository  : https://github.com/crcerror/OpenBOR-63xx-RetroPie-openbeta
# Help		  : https://www.raspberrypi.org/forums/viewtopic.php?f=78&t=26859&start=25
#             : https://retropie.org.uk/forum/topic/19326/openbor-6xxx-openbeta-testphase
#             : https://misapuntesde.com/post.php?id=567
#             : https://drive.google.com/drive/u/0/folders/1NNqFuVfjyjcaS94q5YhSrNqumZ1r8LNi
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"
PACKAGES=(libsdl-gfx1.2-5 libpng16-16 libsdl2-gfx-1.0-0 libvorbisidec1)
PACKAGES_DEV=(libsdl2-gfx-dev libvorbisidec-dev libvpx-dev libogg-dev libsdl2-gfx-1.0-0 libvorbisidec1)
BINARY_URL="https://misapuntesde.com/rpi_share/openbor_by_ulysess.tar.gz"
GITHUB_URL="https://github.com/crcerror/OpenBOR-Raspberry"
DATA_URL="https://archive.org/download/sor-2-x-v-2.1/SOR2X_V2.1.pak"

runme() {
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/openbor && ./openbor
    echo
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/openbor ~/.local/share/applications/openbor.desktop
}

uninstall() {
    read -p "Do you want to uninstall Openbor (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
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

path_libsdl_gfx() {
    if [[ ! -e /usr/lib/arm-linux-gnueabihf/libSDL_gfx.so.13 ]]; then
        echo -e "\nLinking libSDL_gfx..."
        sudo ln -s /usr/lib/arm-linux-gnueabihf/libSDL_gfx.so.15 /usr/lib/arm-linux-gnueabihf/libSDL_gfx.so.13
    fi
}

download_data_files() {
    echo -e "\nDownloading Street Of Rage 2X, please wait..."
    download_file "$DATA_URL" "$INSTALL_DIR"/openbor/Paks
}

install() {
    echo -e "\nInstalling Openbor, please wait..."
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    download_data_files
    path_libsdl_gfx
    generate_icon
    echo -e "\nDone!."
    runme
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p ~/sc && cd "$_" || exit
    echo "Cloning and compiling repo..."
    [[ ! -d ~/sc/openbor ]] && git clone "$GITHUB_URL"
    make clean-all BUILD_PANDORA=1
    patch -p0 -i ./patch/latest_build.diff
    make_with_all_cores BUILD_PANDORA=1 PNDDEV=/usr
    echo -e "\nDone!"
}

echo "
OpenBOR for Raspberry Pi 4
==========================

 · Optimized for Raspberry Pi 4.
 · More Info and games: http://www.chronocrash.com/forum/
 · Game included: Streets Of Rage 2X thanks to Kratus http://www.chronocrash.com/forum/index.php?action=profile;u=13351
 · Install path: $INSTALL_DIR/openbor
 · Some keys: F12 - Menu | 
"
read -p "Press [ENTER] to continue..."

install
