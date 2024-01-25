#!/bin/bash
#
# Description : Dolphin emulator
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.0 (25/Jan/24)
# Tested      : Raspberry Pi 5
#
# Help		  : https://github.com/dolphin-emu/dolphin/wiki/Building-for-Linux
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly BINARY_PATH="https://misapuntesde.com/rpi_share/dolphin_rpi_experimental.tar.xz"
readonly BINARY_64_PATH="https://misapuntesde.com/rpi_share/dolphin-5.0-20978-aarch64.tar.gz"
readonly PACKAGES=(libqt6widgets6)
readonly PACKAGES_DEV=(ffmpeg libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libevdev-dev libusb-1.0-0-dev libxrandr-dev libxi-dev libpangocairo-1.0-0 qt6-base-private-dev libqt6svg6-dev libbluetooth-dev libasound2-dev libpulse-dev libgl1-mesa-dev libcurl4-openssl-dev libudev-dev libsystemd-dev gettext libsdl2-dev libfmt-dev)
readonly SOURCE_PATH="https://github.com/dolphin-emu/dolphin"
readonly CURRENT_PATH="${PWD}"
EXEC_PATH="$HOME/games/dolphin/dolphin-emu"
ICON_PATH="$HOME/games/dolphin/Data/dolphin-emu.svg"

runme() {
    read -p "Press [ENTER] to run the emulator..."
    ${EXEC_PATH}
    exit_message
}

remove_files() {
    sudo rm -rf /usr/local/bin/dolphin-emu /usr/local/lib/libpolarssl.a "$HOME"/.dolphin-emu /usr/local/share/dolphin-emu /usr/local/share/pixmaps ~/.local/share/applications/dolphin.desktop
    rm -rf "$HOME/games/dolphin" "$HOME/.dolphin-emu" "$HOME/.local/share/applications/dolphin.desktop"
}

uninstall() {
    read -p "Do you want to uninstall Dolphin (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -f /usr/local/bin/dolphin-emu || -f $HOME/games/dolphin ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -f /usr/local/bin/dolphin-emu || -f $HOME/games/dolphin ]]; then
    echo -e "Dolphin already installed.\n"
    uninstall
fi

generate_icon() {
    if ! is_kernel_64_bits; then
        cp -f "$CURRENT_PATH"/res/dolphin.png /usr/local/share/dolphin-emu/dolphin.png
        EXEC_PATH="/usr/local/bin/dolphin-emu"
        ICON_PATH="/usr/local/share/dolphin-emu/dolphin.png"
    fi
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/dolphin.desktop ]]; then
        cat <<EOF >~/.local/share/applications/dolphin.desktop
[Desktop Entry]
Name=Dolphin (Wii/Gamecube)
Exec=${EXEC_PATH}
Icon=${ICON_PATH}
Type=Application
Comment=Dolphin is a Wii & Gamecube emulator. This release corresponds to release 4.0
Categories=Game;ActionGame;
EOF
    fi
}

download_binaries() {
    echo -e "\nInstalling binary files..."
    if is_kernel_64_bits; then
        download_and_extract "$BINARY_64_PATH" "$HOME/games"
    else
        download_and_extract "$BINARY_PATH" /tmp
        move_files
    fi
}

move_files() {
    # Move to correspondent directory
    sudo mv -n /tmp/Dolphin/usr/local/bin/dolphin-emu /usr/local/bin/
    sudo mv -n /tmp/Dolphin/usr/local/lib/libpolarssl.a /usr/local/lib/
    sudo mv -n /tmp/Dolphin/usr/local/share/dolphin-emu /usr/local/share/
    sudo mv -n /tmp/Dolphin/usr/local/share/locale /usr/local/share/
    sudo mv -n /tmp/Dolphin/usr/local/share/pixmaps /usr/local/share/
    mv -f /tmp/Dolphin/.dolphin-emu "$HOME"/.dolphin-emu
    rm -rf /tmp/Dolphin
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    echo "Compiling, please wait..."
    make -p "$HOME"/sc && cd "$_" || exit 1
    git clone "$SOURCE_PATH" && cd dolphin || exit 1
    git submodule update --init --recursive Externals/mGBA Externals/spirv_cross Externals/zlib-ng Externals/libspng Externals/VulkanMemoryAllocator Externals/cubeb Externals/implot Externals/gtest Externals/rcheevos Externals/fmt Externals/lz4 Externals/xxhash Externals/enet
    git pull --recurse-submodules
    sed -i 's/option(option(ENABLE_GENERIC "Enables generic build that should run on any little-endian host" OFF)/option(ENABLE_GENERIC "Enables generic build that should run on any little-endian host" ON)/' CMakeLists.txt
    mkdir build && cd "$_" || exit 1
    cmake .. -DLINUX_LOCAL_DEV=true
    make_with_all_cores
    echo -e "\nDone!. Check the code at $HOME/sc/dolphin/build."
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    download_binaries
    generate_icon
    echo
    echo -e "Done!. You can play typing ${EXEC_PATH} or opening the Menu > Games > Dolphin (Wii/Gamecube).\n"
    runme
}

install_script_message
echo "
Install Dolphin emulator - Wii & Gamecube
=========================================

· Dolphin is not supported on Linux ARM devices. It was compiled by myself using generic build, so It's experimental.
"

install
