#!/bin/bash
#
# Description : RPiPlay - Airplay mirroring
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.0 (03/Jan/21)
#
. ./scripts/helper.sh || . ../helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/apps"
readonly PACKAGES=(libavahi-compat-libdnssd1)
readonly PACKAGES_DEV=(cmake libavahi-compat-libdnssd-dev libplist-dev libssl-dev)
readonly BINARY_PATH="https://misapuntesde.com/rpi_share/rpiplay-v1.2.tar.gz"
readonly SOURCE_CODE_URL="https://github.com/FD-/RPiPlay"
INPUT=/tmp/rpiplay.$$

runme() {
    if [[ ! -f $INSTALL_DIR/rpiplay/rpiplay ]]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the app..."
    cd "$INSTALL_DIR/rpiplay" && ./rpiplay
    exit_message
}

remove_files() {
    sudo rm -rf "$INSTALL_DIR"/rpiplay ~/.local/share/applications/rpiplay.desktop
}

uninstall() {
    read -p "Do you want to uninstall RPiPlay (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo apt remove -y libavahi-compat-libdnssd1
        remove_files
        if [[ -e "$INSTALL_DIR"/rpiplay ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d $INSTALL_DIR/rpiplay ]]; then
    echo -e "RPiPlay already installed.\n"
    uninstall
    exit 1
fi

generate_icon() {
    if [[ ! -e ~/.local/share/applications/rpiplay.desktop ]]; then
        cat <<EOF >~/.local/share/applications/rpiplay.desktop
[Desktop Entry]
Name=rpiplay
Exec=${PWD}/rpiplay/rpiplay.sh
Icon=${PWD}/rpiplay/icon.png
Path=${PWD}/rpiplay/
Type=Application
Comment=An open-source implementation of an AirPlay mirroring server for the Raspberry Pi
Categories=ConsoleOnly;Utility;System;
Terminal=true
X-KeepTerminal=true
EOF
    fi
}

download_binaries() {
    echo -e "\nInstalling binary files..."
    download_and_extract "$BINARY_PATH" "$INSTALL_DIR"
}

end_message() {
    echo -e "\nSteps:\n======\n"
    echo "1) You will see a black background here. On your iDevice, open the Control Center by swiping up from the bottom of the device screen or swiping down from the top right corner of the screen (varies by device and iOS version)."
    echo "2) Tap the 'Screen Mirroring' or 'AirPlay' button and connect to RPiPlay."
    echo "3) EXIT: ALT + F4 or CTRL + C"
    echo -e "\n· More info rpiplay -h or visiting $SOURCE_CODE_URL\n"
}

compile() {
    echo -e "\nInstalling dependencies (if proceed)...\n"
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    sudo apt install -y
    cd "$INSTALL_DIR" || exit 1
    git clone "$SOURCE_CODE_URL" rpiplay && cd "$_" || exit 1
    mkdir build && cd "$_" || exit 1
    cmake --DCMAKE_CXX_FLAGS="-O3" --DCMAKE_C_FLAGS="-O3" ..
    echo -e "\n\nCompiling...\n"
    make_with_all_cores
    mv rpiplay ../rpiplay
    end_message
    runme
}

install() {
    install_script_message
    echo -e "\nInstalling dependencies (if proceed)...\n"
    install_packages_if_missing "${PACKAGES[@]}"
    download_binaries
    generate_icon
    echo -e "\nDone. Type $INSTALL_DIR/rpiplay/rpiplay or go to Menu > System Tools > rpiplay.\n"
    end_message
    runme
}

menu() {
    while true; do
        dialog --clear \
            --title "[ RPiPlay ]" \
            --menu "Select from the list:" 11 68 3 \
            INSTALL "Binary (Recommended)" \
            COMPILE "Latest from source code. Estimated time on RPi 4: ~3 minutes." \
            Exit "Exit" 2>"${INPUT}"

        menuitem=$(<"${INPUT}")

        case $menuitem in
        INSTALL) clear && install ;;
        COMPILE) clear && compile ;;
        Exit) exit ;;
        esac
    done
}

menu
