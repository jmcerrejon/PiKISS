#!/bin/bash
#
# Description : Blood
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.11 (16/Mar/25)
# Tested      : Raspberry Pi 5
#
# Help		  : https://www.techradar.com/how-to/how-to-run-wolfenstein-3d-doom-and-duke-nukem-on-your-raspberry-pi
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly BINARY_URL="https://misapuntesde.com/rpi_share/blood_r12112.tar.gz"
readonly BINARY_64_BITS_URL="https://misapuntesde.com/rpi_share/nblood_aarch64.tar.gz"
readonly PACKAGES_DEV=(build-essential nasm libgl1-mesa-dev libglu1-mesa-dev libsdl1.2-dev libsdl-mixer1.2-dev libsdl2-dev libsdl2-mixer-dev flac libflac-dev libvorbis-dev libvpx-dev libgtk2.0-dev freepats)
readonly SOURCE_CODE_URL="https://github.com/nukeykt/NBlood"
readonly VAR_DATA_NAME="BLOOD_FULL"

runme() {
    if [ ! -f "$INSTALL_DIR"/blood/nblood ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/blood && ./nblood
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/blood ~/.local/share/applications/blood.desktop ~/.config/nblood
}

uninstall() {
    read -p "Do you want to uninstall Blood (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/blood ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/blood ]]; then
    echo -e "Blood already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/blood.desktop ]]; then
        cat <<EOF >~/.local/share/applications/blood.desktop
[Desktop Entry]
Name=Blood
Exec=${PWD}/blood/nblood
Icon=${PWD}/blood/blood.png
Path=${PWD}/blood/
Type=Application
Comment=Blood is a fps game.The game follows the story of Caleb, an undead early 20th century gunfighter seeking revenge against the dark god Tchernobog.
Categories=Game;ActionGame;
EOF
    fi
}

# Check https://github.com/nukeykt/NBlood/issues/332
fix_path() {
    echo -e "Fixing code...\n" && sleep 3
    sed -i -e 's/  glrendmode = (settings.polymer) ? REND_POLYMER : REND_POLYMOST;/  int glrendmode = (settings.polymer) ? REND_POLYMER : REND_POLYMOST;/g' source/duke3d/src/startgtk.game.cpp
    sed -i 's/    LIBS += -lrt/    LIBS += -lrt -latomic/g' ./Common.mak
    sed -i 's/    return r;/    return 0;/g' source/build/include/zpl.h
}

compile() {
    echo -e "\nInstalling dependencies (if proceed)...\n"
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    echo
    git clone "$SOURCE_CODE_URL" blood && cd "$_" || exit 1
    echo -e "\n\nCompiling... Estimated time on RPi 4: <5 min.\n"
    make_with_all_cores WITHOUT_GTK=1 POLYMER=1 USE_LIBVPX=0 HAVE_FLAC=0 OPTLEVEL=3 LTO=0 RENDERTYPESDL=1 HAVE_JWZGLES=1 USE_OPENGL=1
    echo -e "\nDone. Copy the data files inside $INSTALL_DIR/blood. You can play typing $INSTALL_DIR/blood/nblood"
    exit_message
}

download_data_files() {
    DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME")
    message_magic_air_copy "$VAR_DATA_NAME"
    download_and_extract "$DATA_URL" "$INSTALL_DIR"
}

install() {
    local INSTALL_BIN_PATH=$BINARY_URL

    echo -e "\n\nInstalling Blood, please wait..."
    mkdir -p "$INSTALL_DIR" && cd "$_" || exit 1
    if is_userspace_64_bits; then
        INSTALL_BIN_PATH=$BINARY_64_BITS_URL
    fi
    download_and_extract "$INSTALL_BIN_PATH" "$INSTALL_DIR"
    generate_icon
    if exists_magic_file; then
        download_data_files
        echo -e "\n\nDone!. You can play typing $INSTALL_DIR/blood/blood or opening the Menu > Games > Blood.\n"
        runme
    fi

    echo -e "\nDone. Copy the data files inside $INSTALL_DIR/blood and then, you can play typing $INSTALL_DIR/blood/nblood or opening the Menu > Games > Blood"
    exit_message
}

install_script_message
echo "
Blood
=====
 · Blood is a fps game.The game follows the story of Caleb, an undead early 20th century gunfighter seeking revenge against the dark god Tchernobog.
 · You need the data files from the original game to play.
 · Install the game and then copy the data files inside $INSTALL_DIR/blood.
"
read -p "Do you want to continue? (y/N) " response
if [[ $response =~ [Nn] ]]; then
    exit_message
fi

install
