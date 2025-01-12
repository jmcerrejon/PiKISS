#!/bin/bash
#
# Description : Source Engine (Portal) installer for Raspberry Pi
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (12/Jan/25)
# Tested      : Raspberry Pi 5
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly GAME_NAME="Portal"
readonly INSTALL_DIR="$HOME/games"
readonly BIN_GAME_SOURCE_DIR="$INSTALL_DIR/portal"
readonly PACKAGES_SOURCE_DEV=(git-all build-essential pkg-config ccache libsdl2-dev libfontconfig1-dev libopenal-dev libjpeg-dev libpng-dev libcurl4-gnutls-dev libbz2-dev libedit-dev)
readonly BINARY_SOURCE_64_BITS_URL="https://misapuntesde.com/rpi_share/source-eng-portal-aarch64.tar.gz"
readonly SOURCE_CODE_URL="https://github.com/nillerusr/source-engine"
readonly VAR_PORTAL_DATA_NAME="PORTAL"

runme_source_engine() {
    read -p "Press [ENTER] to run the game..."
    cd "$BIN_GAME_SOURCE_DIR" && ./launcher.sh
    echo
    exit_message
}

uninstall_source_engine() {
    read -p "Do you want to uninstall $GAME_NAME (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$BIN_GAME_SOURCE_DIR" ~/.local/share/applications/source_portal.desktop
        if [[ -d $BIN_GAME_SOURCE_DIR ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d $BIN_GAME_SOURCE_DIR ]]; then
    echo -e "$GAME_NAME already installed.\n"
    uninstall_source_engine
    exit 0
fi

generate_icon_source_engine() {
    if [[ ! -e ~/.local/share/applications/source_portal.desktop ]]; then
        echo -e "\nGenerating icon..."
        cat <<EOF >~/.local/share/applications/source_portal.desktop
[Desktop Entry]
Name=$GAME_NAME
Exec=${INSTALL_DIR}/portal/launcher.sh
Icon=${INSTALL_DIR}/portal/Icon.png
Path=${INSTALL_DIR}/portal/
Type=Application
Terminal=true
Comment=Players must solve puzzles and challenges based on the laws of physics by opening portals and moving objects, or even their own avatars, through space.
Categories=Game;ActionGame;
EOF
    fi
}

download_data_files_portal() {
    DATA_URL=$(extract_path_from_file "$VAR_PORTAL_DATA_NAME")
    message_magic_air_copy "$VAR_PORTAL_DATA_NAME"
    download_and_extract "$DATA_URL" "$BIN_GAME_DIR"
}

compile_source_engine() {
    install_packages_if_missing "${PACKAGES_SOURCE_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || return 1
    git clone --recursive --depth 1 "$SOURCE_CODE_URL" portal && cd "$_" || return 1
    ./waf configure -T release -j "$(nproc)" --prefix=portal --build-games=portal --disable-warns
    echo -e "\nCompiling, please wait (~20 minutes on RPi 5)..."
    ./waf build -p -v
    ./waf install --destdir="/portal"
    echo -e "\nDone!. Check $BIN_GAME_SOURCE_DIR directory."
}

install_source_engine() {
    download_and_extract "$BINARY_SOURCE_64_BITS_URL" "$INSTALL_DIR"
    generate_icon_source_engine

    echo -e "\nDone!\n"q
    runme_source_engine
}

if ! is_userspace_64_bits; then
    echo -e "\nSorry, only 64-bit OS supported."
    exit_message
fi

install_script_message
echo "
$GAME_NAME
======

 · Based on engine: ${SOURCE_CODE_URL}
 · Better experience at 720p resolution.
 · Steam account with $GAME_NAME game bought is required or demo version will be installed.

 · IMPORTANT!: Run the file ./launcher.sh or click on Menu > Game > $GAME_NAME on Desktop to download the game data files from the Steam account to play. This process works exclusively for a specific version of game data files, so ensure you have your Steam credentials ready before proceeding. PiKISS does not store any of your credentials. Check out the project https://github.com/SteamRE/DepotDownloader for more information.
"
read -p "Press [ENTER] to continue..."
install_source_engine
