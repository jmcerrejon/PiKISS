#!/bin/bash
#
# Description : Gameboy Advance emulator mgba
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.4.0 (03/Nov/20)
# Compatible  : Raspberry Pi 1-3 (¿?), 4 (tested)
# Repository  : https://github.com/mgba-emu/mgba.git
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }
clear

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=( ffmpeg libglu1-mesa libzip4 qtmultimedia5-dev)
readonly PACKAGES_DEV=( cmake libsdl2-dev ffmpeg libnewlib-dev libzip-dev libedit-dev freebsd-glue libsqlite3-dev libelf-dev libepoxy-dev libpng-dev libavcodec-dev libavresample-dev libminizip-dev libavfilter-dev qtmultimedia5-dev qt5-qmake qt5-default qtdeclarative5-dev qttools5-dev)
readonly SOURCE_CODE_URL="https://github.com/mgba-emu/mgba.git"
readonly BINARY_URL="https://misapuntesde.com/rpi_share/mgba_0.90-rpi.tar.gz"

runme() {
    if [ ! -d "$INSTALL_DIR"/mgba ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    echo
    read -p "Press [ENTER] to run..."
    cd "$INSTALL_DIR"/mgba/bin && ./mgba-qt
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR/mgba" ~/.local/share/applications/mgba.desktop ~/.config/mgba
}

uninstall() {
    read -p "Do you want to uninstall mGBA Game Boy Advance Emulator (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/mgba ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/mgba ]]; then
    echo -e "mGBA Game Boy Advance Emulator already installed.\n"
    uninstall
    exit 1
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/mgba.desktop ]]; then
        cat <<EOF >~/.local/share/applications/mgba.desktop
[Desktop Entry]
Name=mGBA Game Boy Advance Emulator
Exec=${INSTALL_DIR}/mgba/bin/mgba-qt
Icon=${INSTALL_DIR}/mgba/share/icons/hicolor/128x128/apps/mgba.png
Type=Application
Comment=mGBA is an emulator for running Game Boy Advance games. It aims to be faster and more accurate than many existing Game Boy Advance emulators
Categories=Game;
EOF
    fi
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_"
    git clone "$SOURCE_CODE_URL" mgba && cd "$_"
    mkdir build && cd "$_"
    CFLAGS="-fsigned-char -marm -march=armv8-a+crc -mtune=cortex-a72 -mfpu=neon-fp-armv8 -mfloat-abi=hard" CXXFLAGS="-fsigned-char" cmake .. -Dbuildtype=release -DCMAKE_INSTALL_PREFIX:PATH=~/games/mgba -DUSE_DEBUGGERS=OFF -DBUILD_STATIC=ON -DBUILD_SHARED=OFF
    make_with_all_cores
}

post_install() {
    cp -ri "$INSTALL_DIR/mgba/share/.config" ~
}

install() {
    echo -e "\nInstalling, please wait..."
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    post_install
    generate_icon
    echo -e "\nDone!. To play, go to Menu > Games > mGBA Game Boy Advance Emulator or $INSTALL_DIR/mgba/bin path and type: ./mgba ../roms/<rom_file>\n"
    runme
}

install_script_message
echo "
Gameboy Advance Emulator (mgba)
===============================

 · Optimized for Raspberry Pi 4.
 · Install path: $INSTALL_DIR/mgba
 · GBA BIOS included.
 · bin/mgba-qt for the GUI frontend or bin/mgba for console.
 · SDL 2 and OpenGL 2.
 · More Info: https://github.com/mgba-emu/mgba
 · Homebrew ROMs included: Rick Dangerous (gba) and A Were Wolf Tale (gba).
 · Keys: A: X | B: Z | L: A | R: S | Start: Enter | Select: Backspace | ALT+F4: Close
"
read -p "Press [ENTER] to continue..."
install
