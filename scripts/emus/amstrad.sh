#!/bin/bash
#
# Description : Amstrad emulator for Raspberry Pi(Amstrad)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (16/Feb/25)
# Tested      : Raspberry Pi 5 (tested)
#
# shellcheck source=../helper.sh
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"
VERSION="4.6.0"
readonly PACKAGES=(libts-0.0-0)
BINARY_URL="https://misapuntesde.com/res/caprice32_4-60.tar.gz"
BINARY_64_BITS_URL="https://misapuntesde.com/rpi_share/caprice32_4-60-aarch64.tar.gz"
SOURCE_CODE_URL="https://github.com/ColinPitrat/caprice32"
GAME_URL="https://www.amstradabandonware.com/mod/upload/ams_en/games_disk/brucelee.zip"

runme() {
    if [[ ! -f $INSTALL_DIR/caprice32/cap32 ]]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run..."
    cd "$INSTALL_DIR"/caprice32 || exit 1
    ./cap32
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/caprice32 ~/.local/share/applications/caprice32.desktop
}

uninstall() {
    read -p "Do you want to uninstall Caprice32 (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/gemrb ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -f $INSTALL_DIR/caprice32/cap32 ]]; then
    echo -e "Caprice32 already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/gemrb.desktop ]]; then
        cat <<EOF >~/.local/share/applications/caprice32.desktop
[Desktop Entry]
Name=Caprice32
Type=Application
Comment=Amstrad emulator for Raspberry Pi
Exec=${INSTALL_DIR}/caprice32/cap32
Icon=${INSTALL_DIR}/caprice32/logo.png
Path=${INSTALL_DIR}/caprice32/
Terminal=false
Categories=Game;Emulator;
EOF
    fi
}

compile() {
    DESTINATION_DIR="$HOME/sc/caprice32"
    [[ -d $DESTINATION_DIR ]] && rm -rf "$DESTINATION_DIR"
    # install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    git clone --depth 1 "$SOURCE_CODE_URL" caprice32 && cd "$_" || exit 1
    echo -e "\nCompiling... Estimated time on RPi 5: < 8 min.\n"
    make_with_all_cores APP_PATH="$PWD"
    echo -e "\nDone!. Check the build dir."
    exit_message
}

install() {
    local BINARY_URL_INSTALL=$BINARY_URL
    local INSTALL_DISK_IR="$INSTALL_DIR"/caprice32/disk

    if is_userspace_64_bits; then
        BINARY_URL_INSTALL=$BINARY_64_BITS_URL
    fi

    echo "Installing dependencies..."
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    echo "Downloading packages..."
    download_and_extract "$BINARY_URL_INSTALL" "$INSTALL_DIR"
    download_and_extract "$GAME_URL" "$INSTALL_DISK_IR"
    generate_icon
    echo "Done!. Go to install path and type: ./cap32. F1 open the menu."
    runme
}

install_script_message
echo "
Caprice32 for Raspberry Pi
==========================

· Version: $VERSION
· F1: Menu
· More Info: ${SOURCE_CODE_URL}
· For load disk, type cat+ENTER to list files
· Type run\"game_name\" to play. For example: run\"brucelee\"
· Added game Bruce Lee (.dsk) to play
"
read -p "Press [Enter] to continue..."

install
