#!/bin/bash
#
# Description : Dethrace is a Carmageddon clone.
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (01/Oct/24)
# Tested      : Raspberry Pi 5
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libsdl2-2.0-0)
readonly CONFIG_DIR="$HOME/.local/share/dethrace"
readonly BINARY_AARCH64_URL="https://misapuntesde.com/rpi_share/dethrace-rpi-aarch64.tar.gz"
readonly SOURCE_CODE_URL="https://github.com/dethrace-labs/dethrace"
readonly ICON_URL="https://cdn2.steamgriddb.com/icon/76fb6fb9cbea7011e49166d9d4ddbc48.png"
readonly VAR_DATA_NAME="CARMAGEDDON"
DATA_URL="https://rr2000.cwaboard.co.uk/R4/PC/carmdemo.zip"
INPUT=/tmp/dethrace.$$

runme() {
    if [ ! -f "$INSTALL_DIR"/dethrace/dethrace ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    echo
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/dethrace && ./dethrace
    exit_message
}

uninstall() {
    read -p "Do you want to uninstall Dethrace (Carmageddon) (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf ~/.local/share/applications/dethrace.desktop ~/.local/share/dethrace "$CONFIG_DIR"/dethrace.png \
        "$INSTALL_DIR"/dethrace /usr/local/share/blender/scripts/addons/dethrace /usr/local/share/games/dethrace
        if [[ -e "$INSTALL_DIR"/dethrace ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/dethrace ]]; then
    echo -e "Dethrace (Carmageddon) already installed.\n"
    uninstall
    exit 1
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    mkdir -p "$CONFIG_DIR"
    wget -q "$ICON_URL" -O "$CONFIG_DIR"/dethrace.png
    if [[ ! -e ~/.local/share/applications/dethrace.desktop ]]; then
        cat <<EOF >~/.local/share/applications/dethrace.desktop
[Desktop Entry]
Name=Dethrace (Carmageddon)
Exec=${INSTALL_DIR}/dethrace/dethrace
Icon=${CONFIG_DIR}/dethrace.png
Type=Application
Comment=Dethrace is a Carmageddon clone compiled for Raspberry Pi.
Categories=Game;ActionGame;
EOF
    fi
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p ~/sc && cd "$_" || exit 1
    git clone "$SOURCE_CODE_URL" dethrace && cd "$_" || exit 1
    git submodule update --init --recursive
    mkdir build && cd "$_" || exit 1
    CFLAGS="-fsigned-char -march=armv8-a+crc -mtune=cortex-a72" CXXFLAGS="-fsigned-char" cmake .. -DBUILD_TOOLS=off -DBUILD_IO_LIBRARY=off -DBUILD_CRASHHANDLER=off -DBUILD_CRASHREPORTER=off -DICON_TYPE=none -DCMAKE_BUILD_TYPE=RelWithDebInfo -Wno-dev

    make_with_all_cores
    echo -e "Done!. Remember to copy game dirs inside final destination.\n"
    exit_message
}

download_data_files() {
    if exists_magic_file; then
        DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME")
        message_magic_air_copy "$VAR_DATA_NAME_EN"
    fi
    download_and_extract "$DATA_URL" $INSTALL_DIR/dethrace
}

install_binaries() {
    echo -e "\nInstalling binary files..."
    download_and_extract "$BINARY_AARCH64_URL" "$INSTALL_DIR"
}

install() {
    mkdir -p "$INSTALL_DIR"
    install_packages_if_missing "${PACKAGES[@]}"
    install_binaries
    generate_icon
    download_data_files
    echo -e "\nDone!. Click on Menu > Games > Dethrace (Carmageddon)."
    runme
}

install_script_message
echo "
Dethrace (Carmageddon)
======================

 · Visit the project at $SOURCE_CODE_URL
 · Demo version will be installed If no copy is present in the file $RESOURCES_DIR/magic_air_copy.txt
 · Tip: Go to Control and enable different alternative configurations.
"
install
