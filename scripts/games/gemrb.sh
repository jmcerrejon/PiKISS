#!/bin/bash
#
# Description : GemRB (EXPERIMENTAL)
# Version     : 0.8.7
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.2 (18/Nov/20)
# Compatible  : Raspberry Pi 4
# Repository  : https://github.com/gemrb/gemrb
# Help        : https://github.com/gemrb/gemrb/blob/master/INSTALL
#             : https://gemrb.org/Manpage.html
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libvorbisidec1 libopenal1 libsdl2-mixer-2.0-0 libpng12-0)
readonly PACKAGES_DEV=(cmake libsdl2-dev libvorbis-dev libopenal-dev libsdl2-mixer-dev libpng-dev libfontconfig1-dev libfreetype6-dev libglew-dev libgles2-mesa-dev)
readonly BINARY_URL=""
readonly SOURCE_CODE_URL="https://github.com/gemrb/gemrb"
readonly DATA_URL="http://download.fileplanet.com/ftp1/052006/bg2_fullinstall.zip?st=81cKF352XL2lgN76khYOcQ&e=1602242280"
INPUT=/tmp/temp.$$

runme() {
    if [ ! -f "$INSTALL_DIR"/gemrb ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/gemrb && ./gemrb
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/gemrb ~/.local/share/applications/gemrb.desktop
}

uninstall() {
    read -p "Do you want to uninstall GemRB (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/gemrb ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/gemrb ]]; then
    echo -e "GemRB already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/gemrb.desktop ]]; then
        cat <<EOF >~/.local/share/applications/gemrb.desktop
[Desktop Entry]
Name=GemRB
Version=1.0
Type=Application
Comment=
Exec=${INSTALL_DIR}/gemrb/gemrb
Icon=${INSTALL_DIR}/gemrb/logo.png
Path=${INSTALL_DIR}/gemrb/
Terminal=false
Categories=Game;
EOF
    fi
}

end_message() {
    echo -e "\n\nDone!. You can play typing $INSTALL_DIR/gemrb/gemrb or opening the Menu > Games > GemRB.\n"
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_"
    git clone "$SOURCE_CODE_URL" gemrb && "$_"
    mkdir build && cd "$_"
    cmake .. -DSDL_BACKEND=SDL2 -DCMAKE_BUILD_TYPE=Release -DOPENGL_BACKEND=GLES -DDISABLE_WERROR=1
    make_with_all_cores
    read -p "Do you want to install globally the app (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo make install
    fi
    echo -e "\nDone!. Check the code at $HOME/sc/gemrb."
    exit_message
}

download_binaries() {
    echo -e "\nInstalling binary files..."
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    download_binaries
    generate_icon
    echo
    read -p "Do you have data files set on the file res/magic-air-copy-pikiss.txt for Baldur's Gate (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        download_data_files "$INSTALL_DIR/gemrb"
        end_message
        runme
    fi

    echo -e "\nCopy the data files inside $INSTALL_DIR/gemrb/UFO."
    install_packages_if_missing gemrb-baldurs-gate-2-data
    end_message
    exit_message
}

echo "
GemRB (Infinite Engine) v0.8.7 for Raspberry Pi
===============================================

 · Optimized for Raspberry Pi 4.
 · AKA Game Engine Made with preRendered Background.
 · Compatible games: Baldur's Gate I & II, Planetscape Torment.
 · GemRB comes with its own demo, but it is trivial.
"
read -p "Press [Enter] to continue..."

install