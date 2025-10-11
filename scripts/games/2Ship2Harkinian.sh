#!/bin/bash
#
# Description : 2Ship2Harkinian - A free port of The Legend of Z3lda: Ocarina of Time
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.2 (11/Oct/25)
# Tested      : Raspberry Pi 5
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libzip4 libtinyxml2-9 libspdlog1.10 libzip5 libtinyxml2-11 libspdlog1.15 libspdlog-dev)
readonly BINARY_64_BITS_URL="https://github.com/AndresJosueToledoCalderon/Compile-2Ship2Harkinian-for-Raspberry-Pi/raw/refs/heads/main/2%20Ship%202%20Harkinian.7z"
readonly ICON_URL="https://github.com/AndresJosueToledoCalderon/Compile-2Ship2Harkinian-for-Raspberry-Pi/raw/refs/heads/main/mmicon.png"
readonly SOURCE_CODE_URL="https://github.com/AndresJosueToledoCalderon/Compile-2Ship2Harkinian-for-Raspberry-Pi"

not_trixie_compatible

uninstall() {
    read -p "Do you want to uninstall 2Ship2Harkinian (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo rm -rf "$INSTALL_DIR"/2s2h ~/.local/share/2s2h ~/.local/share/applications/2s2h.desktop
        if [[ -e "$INSTALL_DIR"/2s2h ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/2s2h ]]; then
    echo -e "2Ship2Harkinian already installed.\n"
    uninstall
fi

generate_icon() {
    wget -q "$ICON_URL" -O "$INSTALL_DIR"/2s2h/icon.png || {
        echo "Failed to download icon. Please check your internet connection."
        exit 1
    }
    echo -e "\n\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/2s2h.desktop ]]; then
        cat <<EOF >~/.local/share/applications/2s2h.desktop
[Desktop Entry]
Name=2Ship2Harkinian
Exec=${INSTALL_DIR}/2s2h/2s2h.elf
Icon=${INSTALL_DIR}/2s2h/icon.png
Path=${INSTALL_DIR}/2s2h
Type=Application
Comment=2Ship2Harkinian is a free port of The Legend of Zelda: Ocarina of Time.
Categories=Game;ActionGame;
EOF
    fi
}

post_install() {
    echo -e "\nPost-installation tasks..."
    sudo ln -s /usr/lib/aarch64-linux-gnu/libzip.so.5 /usr/lib/aarch64-linux-gnu/libzip.so.4
    sudo ln -s /usr/lib/aarch64-linux-gnu/libtinyxml2.so.11 /usr/lib/aarch64-linux-gnu/libtinyxml2.so.9
    sudo ln -s /usr/lib/aarch64-linux-gnu/libspdlog.so.1.15 /usr/lib/aarch64-linux-gnu/libspdlog.so.1.10
    sudo ln -s /usr/lib/aarch64-linux-gnu/libfmt.so.10.1.0 /usr/lib/aarch64-linux-gnu/libfmt.so.9
}

install() {
    echo -e "\n\nInstalling, please wait..."
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_64_BITS_URL" "$INSTALL_DIR"
    mv "$INSTALL_DIR/2 Ship 2 Harkinian" "$INSTALL_DIR/2s2h" || {
        echo "Failed to move the extracted files. Please check the download and extraction process."
        exit 1
    }
    generate_icon
    echo -e "\n\nDone!. Once you copy the ROM file inside $INSTALL_DIR/2s2h, you can play typing $INSTALL_DIR/2s2h/2s2h.elf or opening the Menu > Games > 2Ship2Harkinian.\n"
    echo -e "ALT+ENTER full-screen | SPACE Select | WSAD for move | Arrows for camera, [KL,.] for actions.\n"
    exit_message
}

install_script_message
echo "
2Ship2Harkinian
===============

· Free port of The Legend of Z3lda: Ocarina of Time.
· This is a port of HarbourMasters compiled for the Raspberry Pi by AndresJosueToledoCalderon. Visit $SOURCE_CODE_URL for more information.
· You need a legal copy of the game ROM to play.
"

read -p "Do you want to install 2Ship2Harkinian? (Y/n) " response
if [[ $response =~ [Nn] ]]; then
    exit_message
fi

install
