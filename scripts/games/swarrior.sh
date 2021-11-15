#!/bin/bash
#
# Description : Shadow Warrior
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.2 (14/Nov/21)
# Compatible  : Raspberry Pi 4 (tested)
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly BINARY_URL="https://misapuntesde.com/rpi_share/swarrior-rpi.tar.gz"
readonly TRACKS_URL="https://misapuntesde.com/rpi_share/swarrior_tracks.tar.gz"
readonly PACKAGES=(p7zip)
readonly PACKAGES_DEV=(build-essential nasm libgl1-mesa-dev libglu1-mesa-dev libsdl1.2-dev libsdl-mixer1.2-dev libsdl2-dev libsdl2-mixer-dev flac libflac-dev libvorbis-dev libvpx-dev libgtk2.0-dev freepats)
readonly SOURCE_CODE_URL="https://github.com/jonof/jfsw"
readonly VAR_DATA_NAME="SHADOW_WARRIOR"
DATA_URL="https://misapuntesde.com/rpi_share/swarrior_shareware.tar.gz"

runme() {
    if [[ ! -f $INSTALL_DIR/swarrior/sw ]]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run..."
    cd "$INSTALL_DIR"/swarrior && ./sw
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/swarrior ~/.jwsw ~/.local/share/applications/swarrior.desktop
}

uninstall() {
    read -p "Do you want to uninstall Shadow Warrior (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/swarrior ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/swarrior ]]; then
    echo -e "Shadow Warrior already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/swarrior.desktop ]]; then
        cat <<EOF >~/.local/share/applications/swarrior.desktop
[Desktop Entry]
Name=Shadow Warrior
Exec=${INSTALL_DIR}/swarrior/sw
Icon=${INSTALL_DIR}/swarrior/sw.ico
Path=${INSTALL_DIR}/swarrior/
Type=Application
Comment=Shadow Warrior is fps game developed by 3D Realms.
Categories=Game;ActionGame;
EOF
    fi
}

compile() {
    echo -e "\nInstalling dependencies (if proceed)...\n"
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    cd "$INSTALL_DIR" || exit 1
    git clone "$SOURCE_CODE_URL" swarrior && cd "$_" || exit 1
    git submodule update --init
    make_with_all_cores RELEASE=1 USE_POLYMOST=1 USE_OPENGL=USE_GLES2 WITHOUT_GTK=1
    echo -e "\nDone. Copy the game data files and run ./sw" || exit 0
}

post_install() {
    local DEFAULT_CFG_PATH=
    DEFAULT_CFG_PATH="$HOME/.jwsw"

    echo -e "\nCopying default config...\n"
    [[ ! -e "$DEFAULT_CFG_PATH" ]] && mkdir "$DEFAULT_CFG_PATH"
    cp "$INSTALL_DIR/swarrior/sw.cfg" "$DEFAULT_CFG_PATH"

    echo -e "Copying tracks...\n"
    download_and_extract "$TRACKS_URL" "$INSTALL_DIR/swarrior"
}

install() {
    echo -e "\n\nInstalling Shadow Warrior, please wait..."
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    generate_icon
    post_install
    if exists_magic_file; then
        DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME")
        message_magic_air_copy "$DATA_URL"
    fi

    download_and_extract "$DATA_URL" "$INSTALL_DIR"/swarrior
    echo -e "\nDone!. You can play typing $INSTALL_DIR/swarrior/sw or opening the Menu > Games > Shadow Warrior.\n"
    runme
}

install_script_message
echo "
Shadow Warrior
==============

 · Optimized for Raspberry Pi 4.
 · Install the shareware version by default.
 · More info: https://www.jonof.id.au/jfsw/readme.html
 · Install path: $INSTALL_DIR/swarrior
"

read -p "Press [Enter] to continue or [CTRL]+C to abort..."

install
