#!/bin/bash
#
# Description : Duke Nukem 3D
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.2 (22/Nov/25)
# Tested.     : Raspberry Pi 5
#
# Help		  : https://github.com/nukeykt/NBlood <-- Better than Eduke32 official port for the Pi?
# 			  : http://wiki.eduke32.com/wiki/Building_EDuke32_on_Linux#Prerequisites_for_the_build
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
. ../helper.sh || . ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly BINARY_URL="https://misapuntesde.com/rpi_share/eduke32.tar.gz"
readonly BINARY_64_BITS_URL="https://misapuntesde.com/rpi_share/eduke32_arm64.tar.gz"
readonly PACKAGES=(p7zip)
readonly PACKAGES_DEV=(build-essential nasm libgl1-mesa-dev libglu1-mesa-dev libsdl1.2-dev libsdl-mixer1.2-dev libsdl2-dev libsdl2-mixer-dev flac libflac-dev libvorbis-dev libvpx-dev libgtk2.0-dev freepats)
readonly SOURCE_CODE_URL="https://voidpoint.io/terminx/eduke32.git"
readonly VAR_DATA_NAME="DUKE_ATOM"
DATA_URL="http://hendricks266.duke4.net/files/3dduke13_data.7z"
INPUT=/tmp/eduke32.$$

runme() {
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/eduke32 && ./eduke32
    echo
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/eduke32 ~/.local/share/applications/eduke32.desktop
}

uninstall() {
    read -p "Do you want to uninstall Duke Nukem 3D (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/eduke32 ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/eduke32 ]]; then
    echo -e "Duke Nukem 3D already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/eduke32.desktop ]]; then
        cat <<EOF >~/.local/share/applications/eduke32.desktop
[Desktop Entry]
Name=Duke Nukem 3D
Exec=${PWD}/eduke32/eduke32
Icon=${PWD}/eduke32/icon.png
Type=Application
Comment=Duke Nukem 3D is fps game developed by 3D Realms in 1996.
Categories=Game;ActionGame;
Path=${PWD}/eduke32/
EOF
    fi
}

download_data_files() {
    cd "$INSTALL_DIR/eduke32" || exit 1
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$DATA_URL" "$INSTALL_DIR"/eduke32
}

compile() {
    echo -e "\nInstalling dependencies (if proceed)...\n"
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME"/sc && cd "$_" || exit 1
    git clone "$SOURCE_CODE_URL" eduke32 && cd "$_" || exit 1
    echo -e "\n\nCompiling... Estimated time on RPi 4: <10 min.\n"
    make_with_all_cores WITHOUT_GTK=1 USE_LIBVPX=0 HAVE_FLAC=0 RENDERTYPESDL=1 HAVE_JWZGLES=1 OPTLEVEL=0
    echo -e "\nDone.\n"
    exit_message
}

download_binaries() {
    local INSTALL_URL=$BINARY_URL
    echo -e "\nInstalling binary files. If you don't provide game data file inside res/magic-air-copy-pikiss.txt, shareware version will be installed."
    if is_userspace_64_bits; then
        INSTALL_URL=$BINARY_64_BITS_URL
    fi
    download_and_extract "$INSTALL_URL" "$INSTALL_DIR"
}

ln_libflac_lib_on_32_bit() {
    if [[ ! -f /usr/lib/arm-linux-gnueabihf/libFLAC.so.8 ]]; then
        echo "Fixing libFLAC.so.8..."
        ln -s /usr/lib/arm-linux-gnueabihf/libFLAC.so.12 /usr/lib/arm-linux-gnueabihf/libFLAC.so.8
    fi
}

install() {
    echo -e "\n\nInstalling EDuke32, please wait..."
    mkdir -p "$INSTALL_DIR" && cd "$_" || exit 1
    download_binaries
    generate_icon
    if exists_magic_file; then
        DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME")
        message_magic_air_copy "$VAR_DATA_NAME"
    fi

    if ! is_userspace_64_bits; then
        ln_libflac_lib_on_32_bit
    fi

    download_data_files
    echo -e "\nDone!. You can play typing $INSTALL_DIR/eduke32/eduke32 or opening the Menu > Games > Duke Nukem 3D.\n"
    runme
}

install_script_message
echo "
Duke Nukem 3D for Raspberry Pi
==============================

· WARNING!! There is an issue with the resolution on Raspberry Pi. Try to set at 1280x720 or lower and don't try to change it on the game.

· More Info: https://www.eduke32.com/
· Install path: $INSTALL_DIR/eduke32
· You need the game data files. Shareware version will be installed if you don't provide them.
· If you want to play with the original game data files, copy them to $INSTALL_DIR/eduke32
"
read -p "Press [ENTER] to continue..."
install
