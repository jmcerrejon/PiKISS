#!/bin/bash
#
# Description : Xump
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.3 (20/Jun/21)
# Compatible  : Raspberry Pi 1-4 (tested)
#
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games/"
readonly PACKAGES=(libsdl-mixer1.2)
readonly BINARY_URL="https://www.retroguru.com/xump/xump-v.latest-raspberrypi.zip"

if which "$INSTALL_DIR"/xump_rpi >/dev/null; then
    read -p "Warning!: Xump already installed. Press [ENTER] to exit..."
    exit
fi

generate_icon() {
    echo "Generating icon..."
    if [[ ! -e ~/.local/share/applications/Xump.desktop ]]; then
        cat <<EOF >~/.local/share/applications/Xump.desktop
[Desktop Entry]
Name=Xump
Exec=${PWD}/games/xump/xump_rpi
Icon=terminal
Type=Application
Comment=Xump - The Final Run is a simple multi-platform puzzler by Retroguru
Categories=Game;ActionGame;
Path=${PWD}/games/xump/
EOF
    fi
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$INSTALL_DIR/xump"
    chmod +x "$INSTALL_DIR/xump/xump_rpi"
    generate_icon
    echo -e "Done!. To play, on Desktop go to Menu > Games or via terminal: $INSTALL_DIR/xump and type: ./xump_rpi\n\nEnjoy!"
    exit_message
}

install_script_message
echo "
Install Xump (Raspberry Pi version)
===================================

· More Info: https://www.retroguru.com/xump/
· Install path: $INSTALL_DIR
"

install
