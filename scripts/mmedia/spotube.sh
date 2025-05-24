#!/bin/bash
#
# Description : Spotube (Spotify clone)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (09/Sep/24)
# Tested      : Raspberry Pi 5
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly BINARY_URL="https://github.com/KRTirtho/spotube/releases/download/nightly/spotube-linux-nightly-aarch64.tar.xz"
readonly PACKAGES=(libayatana-appindicator3-1 libmpv2)
runme() {
    if [ ! -f /usr/bin/spotube ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run..."
    /usr/bin/spotube
    exit_message
}

uninstall() {
    read -p "Do you want to uninstall Spotube (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf /usr/bin/spotube ~/.local/share/applications/spotube.desktop /usr/share/icons/spotube ~/.local/share/oss.krtirtho.spotube ~/.local/state/spotube /usr/bin/data /usr/bin/lib
        if [[ -e /usr/bin/spotube ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -e /usr/bin/spotube ]]; then
    echo -e "Spotube is already installed.\n"
    uninstall
fi

install() {
    local TEMP_PATH="/tmp/"

    echo -e "\nInstalling Spotube, please wait..."
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "/tmp"
    sudo mv "$TEMP_PATH/spotube" /usr/bin && chmod +x /usr/bin/spotube
    sudo mv "$TEMP_PATH/data" /usr/bin
    sudo mv "$TEMP_PATH/lib" /usr/bin
    mv "$TEMP_PATH/spotube.desktop" ~/.local/share/applications
    mv "$TEMP_PATH/spotube-logo.png" /usr/share/icons/spotube/spotube-logo.png
    echo -e "\n\nDone!. You can play typing spotube or opening the Menu > Games > Moonlight."
    runme
}

install_script_message
install
