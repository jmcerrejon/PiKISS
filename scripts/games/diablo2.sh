#!/bin/bash
#
# Description : Diablo 2 Exp. Spanish for Raspberry Pi
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.8 (28/Aug/21)
# Compatible  : Raspberry Pi 4 (tested)
#
# Info		  : Thks to PI Labs and Notaz
# Help		  : xrandr --newmode "800x600_60.00"  38.25  800 832 912 1024 600 603 607 624 -hsync +vsync or xrandr --newmode HDMI-1 800x600_60.00
#

. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(wine)
readonly SCRIPT_PATH="$HOME/games/diablo2/diablo2.sh"
readonly BINARY_PATH="https://misapuntesde.com/rpi_share/diablo2-rpi.tar.gz"
readonly VAR_DATA_NAME="DIABLO_2"

remove_files() {
    rm -rf "$INSTALL_DIR"/diablo2 ~/.local/share/applications/diablo2.desktop
}

remove_wine() {
    read -p "Do you want to remove wine? (y/N) " response
    if [[ $response =~ [Yy] ]]; then
        sudo apt remove -y wine
    fi
}

uninstall() {
    read -p "Do you want to uninstall Diablo 2 (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        remove_wine
        if [[ -e "$INSTALL_DIR"/diablo2 ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -f /usr/local/bin/twistver ]]; then
    echo "It's not recommended to install Diablo II on Twister OS at this time due to conflicts with x86 wine."
    exit_message
fi

if [[ -d $INSTALL_DIR/diablo2 ]]; then
    echo -e "Diablo 2 already installed.\n"
    uninstall
    exit 1
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/diablo2.desktop ]]; then
        cat <<EOF >~/.local/share/applications/diablo2.desktop
[Desktop Entry]
Name=Diablo 2 Lord of Destruction
Exec=${INSTALL_DIR}/diablo2/diablo2.sh
Path=${INSTALL_DIR}/diablo2/
Icon=${INSTALL_DIR}/diablo2/diabloII.png
Type=Application
Terminal=true
Comment=Set in the fictional Kingdom of Khanduras in the mortal realm, Diablo makes the player take control of a lone hero battling to rid the world of Diablo
Categories=Game;ActionGame;
EOF
    fi
}

end_message() {
    winecfg >/dev/null &
    echo -e "\nDone. On winecfg, go to Graphics Tab and set Emulate a virtual desktop to 800x600. Then, run $SCRIPT_PATH or click on Menu > Games > Diablo 2 Lord of Destruction."
    exit_message
}

download_data_files() {
    DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME")
    if [[ $DATA_URL == "" ]]; then
        false
        return
    fi
    message_magic_air_copy "$DATA_URL"
    download_and_extract "$DATA_URL" "$INSTALL_DIR"
    true
    return
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_PATH" "$INSTALL_DIR"
    install_mesa
    generate_icon
    if exists_magic_file && download_data_files; then
        end_message
    else
        echo -e "\nDone. Please, copy Diablo 2 file games inside $INSTALL_DIR/diablo2"
        end_message
    fi
}

install_script_message
echo "
Diablo 2
========

 · Thks to Notaz.
 · It uses Wine.
 · Install path: $INSTALL_DIR/diablo2
 · NOTE: It runs on Raspberry Pi 4 only.
"

read -p "Press [Enter] to continue or [CTRL]+C to abort..."

install
