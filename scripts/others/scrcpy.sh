#!/bin/bash
#
# Description : Scrcpy
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.2.1 (15/Mar/24)
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ../helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly VERSION="2.4"
readonly INSTALL_DIR="$HOME/apps"
readonly PACKAGES=(adb ffmpeg libsdl2-2.0-0 libusb-1.0-0)
readonly PACKAGES_DEV=(ffmpeg libsdl2-2.0-0 adb wget gcc git pkg-config meson ninja-build libsdl2-dev libavcodec-dev libavdevice-dev libavformat-dev libavutil-dev libswresample-dev libusb-1.0-0 libusb-1.0-0-dev)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/scrcpy-$VERSION-aarch64.tar.gz"

readonly PREBUILD_SERVER_URL="https://github.com/Genymobile/scrcpy/releases/download/v$VERSION/scrcpy-server-v$VERSION"
https://github.com/Genymobile/scrcpy/releases/download/v2.4/scrcpy-server-v2.4
readonly SOURCE_CODE_URL="https://github.com/Genymobile/scrcpy"

remove_files() {
    sudo rm -rf "$INSTALL_DIR"/scrcpy ~/.local/share/applications/scrcpy.desktop /usr/local/share/scrcpy/scrcpy-server
}

uninstall() {
    read -p "Do you want to uninstall Scrcpy (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/scrcpy ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/scrcpy ]]; then
    echo -e "Scrcpy already installed.\n"
    uninstall
    exit 1
fi

generate_icon() {
    if [[ ! -e ~/.local/share/applications/scrcpy.desktop ]]; then
        cat <<EOF >~/.local/share/applications/scrcpy.desktop
[Desktop Entry]
Name=Scrcpy
Exec=${INSTALL_DIR}/scrcpy/android.sh
Icon=${INSTALL_DIR}/scrcpy/android.jpg
Path=${INSTALL_DIR}/scrcpy/
Type=Application
Terminal=true
X-KeepTerminal=true
Comment=Display and control of Android devices connected on USB
Categories=ConsoleOnly;Utility;System;
EOF
    fi
}

compile() {
    echo -e "\nInstalling dependencies (if proceed)..."
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    install_meson
    mkdir -p ~/sc && cd "$_" || exit 1
    git clone "$SOURCE_CODE_URL" scrcpy && cd "$_" || exit 1
    ./install_release.sh
    exit_message
}

install() {
    echo -e "\nInstalling dependencies (if proceed)...\n"
    install_packages_if_missing "${PACKAGES[@]}"
    echo -e "\nInstalling binary files..."
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    # Server
    sudo mkdir -p /usr/local/share/scrcpy || exit 0
    download_file "$PREBUILD_SERVER_URL" "$INSTALL_DIR/scrcpy"
    sudo mv "$INSTALL_DIR/scrcpy/scrcpy-server-v$VERSION" /usr/local/share/scrcpy/scrcpy-server
    chmod +x /usr/local/share/scrcpy/scrcpy-server
    generate_icon
    echo -e "\nDone. Type $INSTALL_DIR/scrcpy/android.sh or go to Menu > System Tools > Scrcpy. Plug your Android device BEFORE start scrcpy."
    exit_message
}

install_script_message
echo "
Install Scrcpy $VERSION
==================

 · More info scrcpy --help or visiting $SOURCE_CODE_URL
 · Audio forwarding is supported from API 30 (Android 11+).
 · The Android device requires at least API 21 (Android 5.0).
 · Make sure you enabled adb debugging on your device(s) and plug an Android device before start scrcpy.
 · On some devices, you also need to enable an additional option to control it using keyboard and mouse.
 · If you have issues, try to run the app a couple of times through Terminal.

"
read -p "Press [Enter] to continue..."

install
