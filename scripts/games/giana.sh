#!/bin/bash
#
# Description : Giana's Return
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.1 (03/Jan/21)
# Compatible  : NOT WORKING ON Raspberry Pi 4 (tested)
#
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly BINARY_FILE="https://www.retroguru.com/gianas-return/gianas-return-v.latest-raspberrypi.zip"

remove_files() {
    sudo rm -rf "$INSTALL_DIR/gianas" ~/.local/share/applications/gianas.desktop
}

uninstall() {
    read -p "Do you want to uninstall Giana's Return (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/scrcpy ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d $INSTALL_DIR/gianas ]]; then
    echo -e "Giana's Return already installed.\n"
    uninstall
    exit 1
fi

generate_icon() {
    echo "Generating icon..."
    if [[ ! -e ~/.local/share/applications/gianas.desktop ]]; then
        cat <<EOF >~/.local/share/applications/gianas.desktop
[Desktop Entry]
Name=Giana Return
Exec=${PWD}/giana/giana_rpi
Path=${PWD}/giana/
Icon=terminal
Type=Application
Comment=Evil Swampy and his followers have stolen the magic ruby, which made it once possible for Giana and Maria to return from their dream
Categories=Game;ActionGame;
EOF
    fi
}

install() {
    mkdir -p "$INSTALL_DIR" && cd "$_" || exit 1
    download_and_extract "$BINARY_FILE" "$INSTALL_DIR/gianas"
    chmod +x "$INSTALL_DIR/gianas/giana_rpi"
    generate_icon
    echo -e "Done!. To play, on Desktop go to Menu > Games or via terminal, go to $INSTALL_DIR and type: ./giana_rpi\n\nEnjoy!"
    exit_message
}

install_script_message
echo "
Install Giana's Return (Raspberry Pi version)
=============================================

· More Info: https://www.gianas-return.de
· Install path: $INSTALL_DIR/gianas
"

install
