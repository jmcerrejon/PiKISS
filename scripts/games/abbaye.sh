#!/bin/bash
#
# Description : Abbaye des Morts
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.2.0 (23/Jun/24)
# Tested      : Raspberry Pi 5
# Help		  : https://misapuntesde.com/post.php?id=162
#
# TODO        : Build deb pkg
# shellcheck source=../helper.sh
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
    read -p "Do you want to uninstall it (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo apt remove -y abbaye-for-linux-src
    fi
    exit_message
fi

if [[ -d $INSTALL_DIR/abbaye ]]; then
    echo -e "Abbaye des Morts already installed.\n"
    read -p "Do you want to unistall it (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR/abbaye" /usr/share/applications/abbaye.desktop
        if [[ -e $INSTALL_DIR/abbaye ]]; then
            echo -e "I hate when this happens. Try to delete manually.\n"
            exit_message
        fi
        echo -e "\nUninstall completed.\n"
    fi
    exit_message
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications ]]; then
        mkdir -p ~/.local/share/applications
    fi
    cat <<EOF >~/.local/share/applications/abbaye.desktop
[Desktop Entry]
Name=Abbaye des Morts
Exec=${INSTALL_DIR}/abbaye/abbayev2
Icon=${INSTALL_DIR}/abbaye/abbaye.png
Path=${INSTALL_DIR}/abbaye/
Type=Application
Comment=Abbaye des Morts is a retro-style platformer game set in a medieval abbey.
Categories=Game;ActionGame;
EOF
}

build_deb_file() {
    sudo apt install -y git build-essential devscripts dh-make
    dh_make -s -p abbaye_2.0 --createorig
    cd debian || exit 1

    cat <<EOF > control
Package: abbaye-for-linux-src
Version: 2.0
Section: games
Priority: optional
Architecture: all
Depends: libsdl2-mixer-2.0-0, libsdl2-ttf-2.0-0, libsdl2-image-2.0-0, libsdl2-gfx-1.0-0
Maintainer: Jose Cerrejon <ulysess@gmail.com>
Description: Abbaye des Morts for Linux
    Abbaye des Morts is a retro-style platformer game set in a medieval abbey. This package contains the source code for Linux.
EOF


    cat <<EOF > changelog
abbaye-for-linux-src (2.0) unstable; urgency=medium

      * Initial release.

     -- Jose Cerrejon <ulysess@gmail.com>  Wed, 23 Jan 2023 00:00:00 +0000
EOF

    # FIXME It doesn't work. Issue:
    # dpkg-genbuildinfo: error: binary build with no binary artifacts found; .buildinfo is meaningless
    # dpkg-buildpackage: error: dpkg-genbuildinfo --build=binary -O../abbaye_2.0-1_arm64.buildinfo subprocess returned exit status 255
    cd .. && dpkg-buildpackage -b
}

compile() {
    echo -e "\nInstalling dependencies (If proceed)...\n"
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    echo -e "\nCloning repository...\n"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    git clone "$SOURCE_CODE_URL" abbaye && cd "abbaye" || exit 1
    echo -e "\nCompiling...\n"
    make -j"$(nproc)" DATADIR='"\".\""'
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
    generate_icon

    install_done
}

if is_userspace_64_bits; then
    install_64_bits
else
    install_32_bits
fi
