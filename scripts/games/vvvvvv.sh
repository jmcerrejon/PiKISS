#!/bin/bash
#
# Description : VVVVVV (WIP)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.0 (16/02/25)
# Compatible  : Raspberry Pi 4
# Repository  : https://github.com/TerryCavanagh/VVVVVV
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly VERSION="2.4.2"
readonly PACKAGES=(libsdl2-mixer-2.0-0)
readonly PACKAGES_DEV=(libsdl2-dev libsdl2-mixer-dev)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/vvvvvv-2.3dev-rpi.tar.gz"
readonly BINARY_64_BITS_URL="https://misapuntesde.com/rpi_share/vvvvvv-${VERSION}-aarch64.tar.gz"
readonly DATA_GAME_URL="https://thelettervsixtim.es/makeandplay/data.zip"
readonly DATA_GAME_WEBSITE="https://thelettervsixtim.es/makeandplay"
readonly SOURCE_CODE_URL="https://github.com/TerryCavanagh/VVVVVV"

runme() {
    if [ ! -f "$INSTALL_DIR"/vvvvvv/VVVVVV ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run..."
    cd "$INSTALL_DIR"/vvvvvv && ./VVVVVV
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/vvvvvv ~/.local/share/VVVVVV ~/.local/share/applications/vvvvvv.desktop
}

uninstall() {
    read -p "Do you want to uninstall VVVVVV (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/vvvvvv ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/vvvvvv ]]; then
    echo -e "VVVVVV already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/vvvvvv.desktop ]]; then
        cat <<EOF >~/.local/share/applications/vvvvvv.desktop
[Desktop Entry]
Name=VVVVVV
Type=Application
Comment=Smart, minimalist platformer with one simple but brilliant twist: instead of jumping, you need to reverse gravity.
Exec=${INSTALL_DIR}/vvvvvv/VVVVVV
Icon=${INSTALL_DIR}/vvvvvv/icon.ico
Path=${INSTALL_DIR}/vvvvvv/
Terminal=false
Categories=Game;
EOF
    fi
}

end_message() {
    echo -e "\n\nDone!. You can play typing $INSTALL_DIR/vvvvvv/vvvvvv.sh or opening the Menu > Games > VVVVVV."
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || return
    git clone "$SOURCE_CODE_URL" vvvvvv && cd vvvvvv/desktop_version || exit 1
    git submodule init && git submodule update --init --recursive
    cmake -G 'Unix Makefiles' -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_CXX_FLAGS="$(sdl2-config --cflags)" -DCMAKE_EXE_LINKER_FLAGS="$(sdl2-config --libs)"
    make_with_all_cores
    download_file "$DATA_GAME_URL" "$HOME/sc/vvvvvv"
    echo -e "\nDone!. Check the code at $HOME/sc/vvvvvv/desktop_version."
    exit_message
}

post_install() {
    clear
    echo -e "\nThis game is under VVVVV Source Code License v1.0.\nI can download the neccesary public data.zip file for you."
    read -p "(Y)es, do it | (n)o, I prefer to download it by myself? (Y/n) " response
    if [[ $response =~ [Nn] ]]; then
        chromium-browser "$DATA_GAME_WEBSITE" &>/dev/null
        echo -e "Download and copy the file data.zip inside $INSTALL_DIR/vvvvvv"
        end_message
        exit_message
    fi

    download_file "$DATA_GAME_URL" "$INSTALL_DIR/vvvvvv"
    end_message
    runme
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    local BINARY_URL_INSTALL=$BINARY_URL

    if is_userspace_64_bits; then
        BINARY_URL_INSTALL=$BINARY_64_BITS_URL
    fi

    download_and_extract "$BINARY_URL_INSTALL" "$INSTALL_DIR"
    generate_icon
    post_install
}

install_script_message
echo "
VVVVVV: Make and Play edition for Raspberry Pi
==============================================

 · Version: $VERSION for aarch64.
 · VVVVVV Source Code License v1.0. https://thelettervsixtim.es/makeandplay/
 · If you enjoy the game, please consider purchasing a copy at http://thelettervsixtim.es
 · KEYS: Cursors=Movement | Space=Change gravity | Alt+ENTER=Full screen | Enter=Map
"
read -p "Press [Enter] to continue..."

install
