#!/bin/bash
#
# Description : Syncterm (BBS)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.2 (9/Apr/22)
# Compatible  : Raspberry Pi 4 (tested)
# Repository  : http://syncterm.bbsdev.net/ | https://gitlab.synchro.net/main/sbbs
# Help        : https://www.askapache.com/online-tools/figlet-ascii/
#
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/apps"
readonly CONFIG_DIR="$HOME/.syncterm"
readonly PACKAGES=(libncurses5 libncursesw5)
readonly PACKAGES_DEV=(libncurses5-dev libncursesw5-dev libsdl1.2-dev)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/syncterm-1.2d-rpi.tar.gz"
readonly SOURCE_CODE_URL="http://syncterm.bbsdev.net/syncterm-src.tgz"

runme() {
    if [ ! -f "$INSTALL_DIR"/syncterm/syncterm ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run..."
    cd "$INSTALL_DIR"/syncterm && ./syncterm
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/syncterm ~/.local/share/applications/syncterm.desktop
}

uninstall() {
    read -p "Do you want to uninstall SyncTERM (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/syncterm ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/syncterm ]]; then
    echo -e "SyncTERM already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon...\n"
    if [[ ! -e ~/.local/share/applications/syncterm.desktop ]]; then
        cat <<EOF >~/.local/share/applications/syncterm.desktop
[Desktop Entry]
Name=SyncTERM
Version=1.0
Type=Application
Comment=ANSI-BBS Terminal
Exec=${INSTALL_DIR}/syncterm/run.sh
Icon=${INSTALL_DIR}/syncterm/syncterm.png
Path=${INSTALL_DIR}/syncterm/
Categories=TerminalEmulator;Network;Dialup;
Keywords=BBS;Terminal;Ansi;
EOF
    fi
}

end_message() {
    echo -e "\n\nDone!. You can play typing $INSTALL_DIR/syncterm/syncterm or opening the Menu > Games > SyncTERM.\n"
}

compile() {
    local REPOSITORY_PATH
    REPOSITORY_PATH="$HOME/sc/syncterm-$(date +%Y%m%d)/src/syncterm"

    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    download_and_extract "$SOURCE_CODE_URL" "$HOME/sc"
    cd "$REPOSITORY_PATH" || exit 1
    st_path=$(pwd | sed 's/\/syncterm$//g')
    make SRC_ROOT="$st_path"
    make_install_compiled_app
    echo -e "\nDone!. Check the code at $HOME/sc/syncterm."
    cd "$REPOSITORY_PATH" || exit 1
    exit 0
}

post_install() {
    mkdir -p "$CONFIG_DIR" || exit 1
    cp "$INSTALL_DIR/syncterm/syncterm.lst" "$CONFIG_DIR"
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    chmod +x "$INSTALL_DIR/syncterm/syncterm"
    generate_icon
    post_install
    runme
}

echo "

      ___                     ___                       ___           ___      
     /\  \                   /|  |                     /\__\         /\__\     
    /::\  \     ___         |:|  |        ___         /:/ _/_       /:/ _/_    
   /:/\:\__\   /\__\        |:|  |       /\__\       /:/ /\  \     /:/ /\  \   
  /:/ /:/  /  /:/__/      __|:|  |      /:/__/      /:/ /::\  \   /:/ /::\  \  
 /:/_/:/  /  /::\  \     /\ |:|__|____ /::\  \     /:/_/:/\:\__\ /:/_/:/\:\__\ 
 \:\/:/  /   \/\:\  \__  \:\/:::::/__/ \/\:\  \__  \:\/:/ /:/  / \:\/:/ /:/  / 
  \::/__/     ~~\:\/\__\  \::/~~/~      ~~\:\/\__\  \::/ /:/  /   \::/ /:/  /  
   \:\  \        \::/  /   \:\~~\          \::/  /   \/_/:/  /     \/_/:/  /   
    \:\__\       /:/  /     \:\__\         /:/  /      /:/  /        /:/  /    
     \/__/       \/__/       \/__/         \/__/       \/__/         \/__/     

                            .: P R E S E N T :.
"
read -p "Press Enter to continue..."

echo "
SyncTERM for Raspberry Pi
=========================

· More info: https://syncterm.bbsdev.net/ | https://telnetbbsguide.com
· X/Y/ZModem up/downloads
· Full ANSI-BBS, CGTerm Commodore 64 PETSCII, Atari 8-bit ATASCII support & DoorWay support.
· Support for IBM low and high ASCII including the face graphics (☺ and ☻) and card symbols (♥, ♦, ♣, and ♠) which so many other terms have problems with (may not work in curses mode... depends on the terminal being used).
· Multiple screen modes (80x25, 80x28, 80x43, 80x50, 80x60, 132x25, 132x28, 132x30, 132x34, 132x43, 132x50, 132x60).
· ANSI Music (through the sound card) & Auto-login with Synchronet RLogin.
· Telnet, RLogin, SSH, RAW, modem, shell (*nix only) and direct serial connections.
· Supports character pacing for ANSI animation as well as the VT500 ESC[*r sequence to allow dynamic speed changes.
· Comes with 43 standard fonts and allows the BBS to change the current font *and* upload custom fonts. This tool will allow you to create fonts for use with SyncTERM.
· Supports Operation Overkill ][ Terminal emulation.
· Thanks to pAULIE42o (2o fOr beeRS bbS).
"

read -p "Press Enter to continue..."

install
