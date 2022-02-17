#!/bin/bash
#
# Description : Abbaye des Morts
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.0 (17/Feb/22)
# Tested      : Raspberry Pi 4
# Help		  : https://misapuntesde.com/post.php?id=162
#
. ./scripts/helper.sh || . ../helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"
readonly BINARY_32_BITS_URL="https://misapuntesde.com/rpi_share/abbaye-des-morts_2-0_armhf.deb"
readonly BINARY_64_BITS_URL="https://misapuntesde.com/rpi_share/abbaye-des-morts_2-0_aarch64.tar.gz"
readonly PACKAGES=(libsdl2-mixer-2.0-0 libsdl2-ttf-2.0-0 libsdl2-image-2.0-0 libsdl2-gfx-1.0-0)
readonly PACKAGES_DEV=(gcc libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl-ttf2.0-dev libsdl-gfx1.2-dev)
readonly SOURCE_CODE_URL="https://github.com/nevat/abbayedesmorts-gpl"

if isPackageInstalled abbaye-for-linux-src; then
    echo -e "\nAbbaye des Morts is already installed.\n"
    exit_message
fi

compile() {
    echo -e "\nInstalling dependencies (If proceed)...\n"
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    echo -e "\nCloning repository...\n"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    git clone "$SOURCE_CODE_URL" && cd "abbaye-for-linux" || exit 1
    echo -e "\nCompiling...\n"
    make -j"$(nproc)" abbaye
    echo -e "Done!..."
    exit_message
}

install_done() {
    echo -e "\nType in a terminal abbayev2 or go to Start button > Games > Abbaye des Morts."
    exit_message
}

install_32_bits() {
    echo -e "\nInstalling Abbaye des Morts, please wait..."
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_install "$BINARY_32_BITS_URL"

    install_done
}

install_64_bits() {
    echo -e "\nInstalling Abbaye des Morts, please wait..."
    install_packages_if_missing "${PACKAGES[@]}"

    download_and_extract "$BINARY_64_BITS_URL" "$INSTALL_DIR"
    install_done
}

if is_userspace_64_bits; then
    install_64_bits
else
    install_32_bits
fi
