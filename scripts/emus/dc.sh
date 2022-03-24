#!/bin/bash
#
# Description : Redream Sega Dreamcast emulator
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.2 (24/Mar/22)
#
# Website     : https://redream.io/
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }
clear

readonly INSTALL_DIR="$HOME/games"
readonly BINARY_URL="https://misapuntesde.com/rpi_share/redream.universal-raspberry-linux-v1.5.0-1043-gd3a6df2.tar.gz"
readonly DATA_GAME_URL="http://volgarr.rkd.zone/VolgarrDC_2015-10-15.zip"

runme() {
    if [ ! -d "$INSTALL_DIR"/redream ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    echo
    read -p "Press [ENTER] to run..."
    cd "$INSTALL_DIR"/redream && ./redream
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR/redream" ~/.local/share/applications/redream.desktop
}

uninstall() {
    read -p "Do you want to uninstall Sega Dreamcast emulator Redream (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/redream ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/redream ]]; then
    echo -e "Sega Dreamcast emulator Redream already installed.\n"
    uninstall
    exit 1
fi

generate_icon() {
    local ICON
    ICON="https://cdn6.aptoide.com/imgs/7/8/e/78eb93bfc786f02312b165e174be68d7_icon.png?w=160"

    echo -e "\nGenerating icon..."
    wget -q -O "$INSTALL_DIR"/redream/icon.png "$ICON"
    if [[ ! -e ~/.local/share/applications/redream.desktop ]]; then
        cat <<EOF >~/.local/share/applications/redream.desktop
[Desktop Entry]
Name=Sega Dreamcast emulator (Redream)
Exec=${INSTALL_DIR}/redream/redream
Icon=${INSTALL_DIR}/redream/icon.png
Type=Application
Comment=Redream is a Dreamcast emulator, enabling you to play your favorite Dreamcast games in high-definition
Categories=Game;
EOF
    fi
}

fix_32_bits() {
    echo -e "\nFixing 32 bits..."

    [[ -e "$INSTALL_DIR"/redream/redream ]] && rm "$INSTALL_DIR"/redream/redream
    [[ -e $INSTALL_DIR/redream/redream.aarch32.elf ]] && mv "$INSTALL_DIR"/redream/redream.aarch32.elf "$INSTALL_DIR"/redream/redream
}

install_game() {
    echo -e "\nInstalling Homebrew game, please wait..."
    mkdir -p "$INSTALL_DIR"/redream/cdi/volgarr
    download_and_extract "$DATA_GAME_URL" "$INSTALL_DIR"/redream/cdi/volgarr
}

install() {
    echo -e "\nInstalling, please wait..."
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"/redream
    if ! is_userspace_64_bits; then
        fix_32_bits
    fi
    install_game
    generate_icon
    echo -e "\nDone!. To play, go to Menu > Games > Sega Dreamcast emulator (Redream) or type $INSTALL_DIR/redream/redream\n"
    runme
}

install_script_message
echo "
Sega Dreamcast emulator (Redream)
=================================

 · Install path: $INSTALL_DIR/redream
 · Homebrew game included: Volgarr.
 · Compatibility Info: https://redream.io/compatibility
"
read -p "Press [ENTER] to continue..."
install
