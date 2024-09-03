#!/bin/bash
#
# Description : UxPlay - Airplay mirroring
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.3.1 (04/Sep/24)
# Tested      : Raspberry Pi 5
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ../helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/apps"
readonly PACKAGES=(libavahi-compat-libdnssd1 libgstreamer1.0-0 libgstreamer-plugins-base1.0-0 gstreamer1.0-tools gstreamer1.0-libav gstreamer1.0-plugins-good)
readonly PACKAGES_DEV=(cmake libavahi-compat-libdnssd-dev libplist-dev libssl-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/uxplay-rpi-all.tar.gz"
readonly SOURCE_CODE_URL="https://github.com/FDH2/UxPlay"

runme() {
    if [[ ! -f $INSTALL_DIR/uxplay/uxplay ]]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the app..."
    cd "$INSTALL_DIR/uxplay" && ./run.sh
    exit_message
}

uninstall() {
    read -p "Do you want to uninstall UxPlay (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo apt remove -y libavahi-compat-libdnssd1
        sudo rm -rf "$INSTALL_DIR"/uxplay ~/.local/share/applications/uxplay.desktop
        if [[ -e "$INSTALL_DIR"/uxplay ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d $INSTALL_DIR/uxplay ]]; then
    echo -e "UxPlay already installed.\n"
    uninstall
    exit 1
fi

generate_icon() {
    if [[ ! -e ~/.local/share/applications/uxplay.desktop ]]; then
        cat <<EOF >~/.local/share/applications/uxplay.desktop
[Desktop Entry]
Name=UxPlay
Exec=${PWD}/uxplay/run.sh
Icon=${PWD}/uxplay/icon.png
Path=${PWD}/uxplay/
Type=Application
Comment=An open-source implementation of an AirPlay mirroring server for the Raspberry Pi
Categories=ConsoleOnly;Utility;System;
Terminal=true
X-KeepTerminal=true
EOF
    fi
}

download_binaries() {
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
}

end_message() {
    echo -e "\nSteps:\n======\n"
    echo "1) You will see a black background here. On your iDevice, open the Control Center by swiping up from the bottom of the device screen or swiping down from the top right corner of the screen (varies by device and iOS version)."
    echo "2) Tap the 'Screen Mirroring' or 'AirPlay' button and connect to UxPlay."
    echo "3) EXIT: ALT + F4 or CTRL + C"
    echo -e "\n· More info uxplay -h or visiting $SOURCE_CODE_URL\n"
}

compile() {
    echo -e "\nInstalling dependencies (If proceed)...\n"
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p ~/sc && cd "$_" || exit 1
    git clone "$SOURCE_CODE_URL" uxplay && cd "$_" || exit 1
    mkdir build && cd "$_" || exit 1
    cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo ..
    echo -e "\nCompiling at ~/sc/uxplay, please wait..."
    make_with_all_cores
    mv uxplay ../uxplay
    end_message
    exit_message
}

install() {
    echo -e "\nInstalling dependencies (if proceed)...\n"
    install_packages_if_missing "${PACKAGES[@]}"
    download_binaries
    generate_icon
    echo -e "\nDone. Type $INSTALL_DIR/uxplay/uxplay or go to Menu > System Tools > uxplay.\n"
    end_message
    runme
}

install_script_message
echo "
UXPlay - Airplay mirroring
==========================

 · Raspberry Pi support both with and without hardware video decoding by the Broadcom GPU.
 · Tested on Raspberry Pi Zero 2 W, 3 Model B+, 4 Model B, and 5.
 · Use uxplay -h for help.
 · More info: $SOURCE_CODE_URL
"
install
