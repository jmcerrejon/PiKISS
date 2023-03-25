#!/bin/bash
#
# Description : Gameboy Advance emulator mgba
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.5.3 (28/Jan/23)
# Compatible  : Raspberry Pi 4 (tested)
# Repository  : https://github.com/mgba-emu/mgba.git
# Help        : 32 bits fix compilation at https://github.com/mgba-emu/mgba/issues/1081
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }
clear

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(ffmpeg libglu1-mesa libzip4 qtmultimedia5-dev libqt5multimedia5 libqt5opengl5)
readonly PACKAGES_DEV=(qtbase5-dev-tools qtbase5-dev cmake libsdl2-dev ffmpeg libnewlib-dev libzip-dev libedit-dev libsqlite3-dev libelf-dev libepoxy-dev libpng-dev libavcodec-dev libavresample-dev libminizip-dev libavfilter-dev qtmultimedia5-dev qt5-qmake qtdeclarative5-dev qttools5-dev zipcmp zipmerge ziptool)
readonly SOURCE_CODE_URL="https://github.com/mgba-emu/mgba.git"
readonly BINARY_URL="https://misapuntesde.com/rpi_share/mgba-0.11-rpi-aarch64.tar.gz"
readonly BINARY_64_BITS_URL="https://misapuntesde.com/rpi_share/mgba-0.11-rpi-aarch64.tar.gz"
readonly GAME_URL="https://web.archive.org/web/20080625061600/http://www.freewebs.com/worldtreegames/TyrianGBA.zip"

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
Categories=Game;Emulator;
EOF
    fi
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    git clone "$SOURCE_CODE_URL" mgba && cd "$_" || exit 1
    mkdir build && cd "$_" || exit 1
    if is_kernel_64_bits; then
        cmake -DCMAKE_INSTALL_PREFIX:PATH="$HOME/games/mgba" ..
    else
        cmake -DCMAKE_INSTALL_PREFIX:PATH="$HOME/games/mgba" -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_CXX_FLAGS="-march=armv8-a -mtune=cortex-a72" ..
    fi
    make_with_all_cores
    echo "Done!. Check $HOME/sc/mgba/build/qt/mgba-qt and $HOME/sc/mgba/build/sdl/mgba"
    exit_message
}

post_install() {
    cp -ri "$INSTALL_DIR/mgba/share/.config" ~
}

install() {
    echo -e "\nInstalling, please wait..."
    install_packages_if_missing "${PACKAGES[@]}"
    if is_kernel_64_bits; then
        download_and_extract "$BINARY_64_BITS_URL" "$INSTALL_DIR"
    else
        download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    fi
    # post_install # TODO: Recover file from compressed file
    generate_icon
    echo -e "\nDone!. To play, go to Menu > Games > mGBA Game Boy Advance Emulator or $INSTALL_DIR/mgba/bin path and type: ./mgba ../roms/<rom_file>\n"
    runme
}

install_script_message
echo "
Gameboy Advance Emulator (mgba)
===============================

 · Optimized for Raspberry Pi 4 | Thks Foxhound311 for the tips.
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
