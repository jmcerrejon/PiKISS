#!/bin/bash
#
# Description : scrcpy thks to Pi Labs
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.2 (03/Jan/21)
#
. ./scripts/helper.sh || . ../helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME"
readonly PACKAGES=(adb ffmpeg libsdl2-2.0-0)
readonly BINARY_PATH="https://misapuntesde.com/rpi_share/scrcpy-1.13.tar.gz"
readonly SOURCE_CODE_URL="https://github.com/Genymobile/scrcpy"

remove_files() {
    sudo rm -rf "$INSTALL_DIR"/scrcpy /usr/local/share/scrcpy ~/.local/share/applications/scrcpy.desktop
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
Exec=${PWD}/scrcpy/android.sh
Icon=${PWD}/scrcpy/android.jpg
Path=${PWD}/scrcpy/
Type=Application
Comment=Display and control of Android devices connected on USB
Categories=ConsoleOnly;Utility;System;
EOF
    fi
}

install() {
    echo -e "\nInstalling dependencies (if proceed)...\n"
    install_packages_if_missing "${PACKAGES[@]}"
    echo -e "\nInstalling binary files..."
    download_and_extract "$BINARY_PATH" "$INSTALL_DIR"
    sudo mkdir -p /usr/local/share/scrcpy
    sudo cp -f "$HOME/scrcpy/scrcpy-server" /usr/local/share/scrcpy/scrcpy-server
    generate_icon
    echo -e "\nDone. Type $INSTALL_DIR/scrcpy/android.sh or go to Menu > System Tools > Scrcpy.\n"
    exit_message
}

install_script_message
echo "
Install Scrcpy
==============

 · More info scrcpy --help or visiting $SOURCE_CODE_URL
 · The Android device requires at least API 21 (Android 5.0).
 · Make sure you enabled adb debugging on your device(s).
 · On some devices, you also need to enable an additional option to control it using keyboard and mouse.
 · If you have issues, try to run the app a couple of times through Terminal.

"
read -p "Press [Enter] to continue..."

install
