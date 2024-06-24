#!/bin/bash
#
# Description : Aliens versus Predator for aarch64
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.0 (24/Jun/24)
# Tested      : Raspberry Pi 5
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libsdl2-2.0-0 libopenal1 libc6)
readonly PACKAGES_DEV=(libsdl2-2.0-0-dev libopenal1-dev libc6-dev)
readonly BINARY_64_BITS_URL="https://e.pcloud.link/publink/show?code=XZwaxTZmBATjuuptQQrYgMAveYGTL4IjKVX"
readonly SOURCE_CODE_URL="https://github.com/atsb/NakedAVP"

runme() {
    echo
    if [ ! -f "$INSTALL_DIR"/avp/avp ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/avp && ./avp -f
    clear
    exit_message
}

uninstall() {
    read -p "Do you want to uninstall AVP (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR"/avp ~/.local/share/applications/avp.desktop ~/.avp
        if [[ -e "$INSTALL_DIR"/avp ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/avp ]]; then
    echo -e "Aliens versus Predator already installed.\n"
    uninstall
    exit 1
fi

if ! is_userspace_64_bits; then
    echo -e "Sorry,Aliens versus Predator only works on 64-bit OS.\n"
    exit_message
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/avp.desktop ]]; then
        cat <<EOF >~/.local/share/applications/avp.desktop
[Desktop Entry]
Name=Aliens versus Predator
Exec=${INSTALL_DIR}/avp/avp -f
Icon=${INSTALL_DIR}/avp/avp.ico
Path=${INSTALL_DIR}/avp/
Type=Application
Comment=Offers three separate campaigns, each playable as a separate species: Alien, Predator, or human Colonial Marine.
Categories=Game;ActionGame;
EOF
    fi
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    git clone "$SOURCE_CODE_URL" && cd NakedAVP || exit 1
    cd "$DIR_NAME" || exit 1
    mkdir build && cd "$_" || exit 1
    cmake -DSDL_TYPE=SDL2 -DOPENGL_TYPE=OPENGL -DCMAKE_C_FLAGS="-march=armv8-a+crc+simd" -DCMAKE_CXX_FLAGS="-march=armv8-a+crc+simd" -DCMAKE_EXE_LINKER_FLAGS="-g" -Wno-dev ..
    make_with_all_cores
    echo "Done!."
}

post_install() {
    if [[ ! -d "$INSTALL_DIR"/avp/.avp ]]; then
        return 0
    fi

    [[ ! -d "$INSTALL_DIR"/avp/.avp ]] && cp -rf "$INSTALL_DIR"/avp/.avp "$HOME"
}

install() {
    echo -e "\nInstalling Aliens versus Predator (1999 video game), please wait..."
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_64_BITS_URL" "$INSTALL_DIR"
    post_install
    generate_icon
    echo
    read -p "Do you have data files set on the file res/magic-air-copy-pikiss.txt for Aliens versus Predator (1999 video game) (y/N)?: " response
    if [[ $response =~ [Nn] ]]; then
        rm -rf "$INSTALL_DIR"/avp/avp_huds "$INSTALL_DIR"/avp/avp_rifs "$INSTALL_DIR"/avp/fastfile
        echo -e "\nCopy your files with lowew case on $INSTALL_DIR/avp, cd into the game directory and type ./avp -f (f for full screen)"
        exit_message
    fi
    echo -e "\nType in a terminal $INSTALL_DIR/avp/avp or go to Menu > Games > Aliens versus Predator."
    runme
}

install_script_message
echo "
Install Aliens versus Predator
==============================

 · Optimized for Raspberry Pi.
 · Install path: $INSTALL_DIR/avp
 · This version has no videos (DRM protected) and no ripped CD audio.
 · Change the video resolution to fit your screen, exit the game and run it again.
"

install
