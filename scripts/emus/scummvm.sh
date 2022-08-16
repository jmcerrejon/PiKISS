#!/bin/bash
#
# Description : ScummVM
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.0 (16/Aug/22)
# Compatible  : Raspberry Pi 1-4 (tested)
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

BASE_DIR="$HOME/games"
INSTALL_DIR="$BASE_DIR/scummvm"
VERSION="2.7.0"
PACKAGES=(libSDL2-net-2.0-0 speech-dispatcher speech-dispatcher-espeak-ng)
PACKAGES_DEV=(libsdl2-dev liba52-0.7.4-dev libjpeg62-turbo-dev libmpeg2-4-dev libogg-dev libvorbis-dev libflac-dev libmad0-dev libpng-dev libtheora-dev libfaad-dev libfluidsynth-dev libfreetype6-dev libcurl4-openssl-dev libsdl2-net-dev libspeechd-dev zlib1g-dev libfribidi-dev libglew-dev)
BINARY_URL="https://misapuntesde.com/rpi_share/scummvm-$VERSION-rpi-all.tar.gz"
SOURCE_CODE_URL="https://github.com/scummvm/scummvm"

uninstall() {
    read -p "Do you want to uninstall ScummVM (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR" ~/.config/scummvm ~/.local/share/applications/scummvm.desktop
        if [[ -e $INSTALL_DIR ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d $INSTALL_DIR ]]; then
    echo -e "ScummVM $VERSION already installed.\n"
    uninstall
    exit 1
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/scummvm.desktop ]]; then
        cat <<EOF >~/.local/share/applications/scummvm.desktop
[Desktop Entry]
Name=ScummVM
Version=${VERSION}
Type=Application
Comment=Multiple Arcade Machine Emulator
Exec=${INSTALL_DIR}/scummvm
Icon=${INSTALL_DIR}/scummvm.svg
Path=${INSTALL_DIR}/
Terminal=false
Categories=Game;Emulator;
EOF
    fi
}

compile() {
    # INFO https://wiki.scummvm.org/index.php/Compiling_ScummVM/RPI
    # INFO https://wiki.scummvm.org/index.php?title=Main_Page
    export LDFLAGS="-Wl,--no-keep-memory"
    local SOURCE_CODE_PATH="$HOME/sc"

    mkdir -p "$SOURCE_CODE_PATH" && cd "$_" || exit 1
    install_packages_if_missing "${PACKAGES_DEV[@]}"

    git clone "$SOURCE_CODE_URL" scummvm && cd "$_" || exit 1
    mkdir -p "$INSTALL_DIR" || exit 1

    if is_userspace_64_bits; then
        ./configure --disable-debug --enable-release --prefix="$INSTALL_DIR"
    else
        ./configure --host=raspberrypi --disable-debug --enable-release --prefix="$INSTALL_DIR"
    fi

    echo -e "\nCompiling, It can takes 65-75 minutes...\n"
    make_with_all_cores
    echo -e "\nDone!.\n"
    exit_message
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$BASE_DIR"
    echo -e "\nCopying config files..."
    cp -r "$INSTALL_DIR/.config/scummvm" "$HOME/.config"
    generate_icon

    echo -e "\nDone!. To play, on Desktop Menu > games or $INSTALL_DIR/run.sh\n"
    read -p "Press [Enter] to go back to the menu..."
}

install_script_message
echo "
ScummVM
=======

· Version $VERSION.
· More Info: https://www.scummvm.org/ | https://docs.scummvm.org/_/downloads/en/latest/pdf/
· Get free games: https://www.scummvm.org/games/
· Install path: $INSTALL_DIR/games
"

install
