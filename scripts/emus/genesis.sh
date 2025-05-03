#!/bin/bash
#
# Description : Picodrive
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.3.0 (03/May/25)
# Tested      : Raspberry Pi 5
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly VERSION_NUMBER="2.04"
readonly INSTALL_DIR="$HOME/games"
readonly BINARY_64_BITS_URL="https://misapuntesde.com/rpi_share/picodrive-aarch64.tar.gz"
readonly ROM_GAME_URL="https://www.mojontwins.com/juegos/mojon-twins--mega-cheril-perils.zip"
readonly GAME_FILE_NAME="mojon-twins--mega-cheril-perils.bin"
readonly SOURCE_CODE_URL="https://github.com/irixxxx/picodrive"

runme() {
    if [[ -f $INSTALL_DIR/picodrive/roms/$GAME_FILE_NAME ]]; then
        read -p "Press [ENTER] to run the emulator..."
        cd "$INSTALL_DIR/picodrive" && ./picodrive "roms/$GAME_FILE_NAME"
    fi
    exit_message
}

uninstall() {
    read -p "Do you want to uninstall Picodrive (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR"/picodrive ~/.local/share/applications/picodrive.desktop ~/.picodrive
        if [[ -e $INSTALL_DIR/picodrive ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d $INSTALL_DIR/picodrive ]]; then
    echo -e "Picodrive already installed.\n"
    uninstall
fi

generate_icon() {
    if [[ ! -e ~/.local/share/applications/picodrive.desktop ]]; then
        echo -e "Creating shortcut...\n"
        cat <<EOF >~/.local/share/applications/picodrive.desktop
[Desktop Entry]

Version=1.0
Name=Picodrive
Comment=Play Sega Genesis games
Exec=$INSTALL_DIR/picodrive/picodrive
Icon=$INSTALL_DIR/picodrive/logo.png
Terminal=false
Type=Application
Categories=Game;
EOF
    fi
}

compile() {
    echo -e "\nCompiling Picodrive..."
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    git clone "$SOURCE_CODE_URL" picodrive && cd "$_" || exit 1

}

install() {
    download_and_extract "$BINARY_64_BITS_URL" "$INSTALL_DIR"
    download_and_extract "$ROM_GAME_URL" "$INSTALL_DIR/picodrive/roms"

    generate_icon

    echo "Done!. To play go to install path, copy any ROM file to $INSTALL_DIR/picodrive and type: ./PicoDrive <game name>"
    runme
    read -p "Press [Enter] to continue..."
    exit
}

install_script_message
echo "
Picodrive
=========

· Version $VERSION_NUMBER | URL: $SOURCE_CODE_URL
· Optimized for Raspberry Pi 4+.
· OpenGLES support.
· Add game Cheril Perils.
"

install
