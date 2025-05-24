#!/bin/bash
#
# Description : VICE Commodore 64
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.3 (7/Oct/22)
# Compatible  : Raspberry Pi 4
#
. ../helper.sh || . ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly VERSION=3.6.1
readonly PACKAGES=(libsdl2-image-2.0-0)
readonly PACKAGES_DEV=(subversion autoconf flex bison xa65 libasound2-dev libsdl2-dev libsdl2-image-dev texinfo libglew-dev libieee1284-3-dev)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/vice-${VERSION}-bin-armhf-rpi.tar.gz"
readonly BINARY_64_BITS_URL="https://misapuntesde.com/rpi_share/vice-${VERSION}-bin-aarch64-rpi.tar.gz"
readonly SOURCE_CODE_URL="https://sourceforge.net/projects/vice-emu/files/releases/vice-${VERSION}.tar.gz"

runme() {
    if [ ! -f "$INSTALL_DIR/vice/x64sc" ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run Old Tower (Directional Keys = OPQA)..."
    cd "$INSTALL_DIR"/vice && ./x64sc -autostartprgmode 1 IMAGES/prg/ot64.prg
    exit_message
}

remove_files() {
    [[ -d "$INSTALL_DIR"/vice ]] && rm -rf "$INSTALL_DIR"/vice ~/.config/vice ~/.local/share/applications/vice.desktop
}

uninstall() {
    read -p "Do you want to uninstall VICE (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/vice ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -e $INSTALL_DIR/vice ]]; then
    echo -e "vice already installed.\n"
    uninstall
fi

generate_icon() {
    if [[ ! -e ~/.local/share/applications/vice.desktop ]]; then
        cat <<EOF >~/.local/share/applications/vice.desktop
[Desktop Entry]
Name=VICE
Exec=${INSTALL_DIR}/vice/x64sc
Path=${INSTALL_DIR}/vice/
Icon=${INSTALL_DIR}/vice/icon.png
Type=Application
Comment=VICE emulates the C64, the C64DTV, the C128, the VIC20, practically all PET models, the PLUS4 and the CBM-II (aka C610/C510). An extra emulator is provided for C64 expanded with the CMD SuperCPU.
Categories=Game;Emulator;
EOF
    fi
}

compile() {
    local VICE_DIR_PATH="$HOME/sc/vice-$VERSION"

    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p ~/sc && cd "$_" || exit
    echo "Cloning and compiling repo..."
    [[ ! -d $VICE_DIR_PATH ]] && download_and_extract "$SOURCE_CODE_URL" "$HOME/sc"
    cd "$VICE_DIR_PATH" || exit
    make distclean
    ./autogen.sh
    ./configure --enable-sdlui2 --disable-pdf-docs
    make_with_all_cores
    # Essential files: x* /data | x128 x64 x64dtv x64sc xcbm2 xcbm5x0 xpet xplus4 xscpu64 xvic
    echo -e "\nDone!. Check the directory $VICE_DIR_PATH/src"
    exit_message
}

install() {
    local BINARY_URL_INSTALL=$BINARY_URL

    if is_userspace_64_bits; then
        BINARY_URL_INSTALL=$BINARY_64_BITS_URL
    fi

    install_packages_if_missing "${PACKAGES_DEV[@]}"
    download_and_extract "$BINARY_URL_INSTALL" "$INSTALL_DIR"
    generate_icon
    echo -e "\n\nDone!. You can play typing $INSTALL_DIR/vice/x64sc or opening the Menu > Games > VICE.\n"
    runme
}

install_script_message
echo "
VICE Commodore64 for Raspberry Pi
=================================

 · Version $VERSION
 · More Info: https://vice-emu.sourceforge.io | https://www.c64-wiki.com/wiki/Main_Page
 · ROMs & 2 Games included: Old Tower (IMAGES/prg/ot64) & Santron (IMAGES/prg/santron.prg)
 · Install path: $INSTALL_DIR/vice
 · TIP: F12 = Menu.
"

install
