#!/bin/bash
#
# Description : Aliens versus Predator
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (02/Aug/20)
# Compatible  : Raspberry Pi 4 (tested)
#
# Help		  : https://www.raspberrypi.org/forums/viewtopic.php?t=100152
#

. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly BINARY_URL=$(extract_url_from_file 9)

runme() {
    echo
    if [ ! -f "$INSTALL_DIR"/avp/avp ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/avp && ./avp -f
    clear
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/avp ~/.local/share/applications/avp.desktop ~/.avp
}

uninstall() {
    read -p "Do you want to uninstall AVP (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/avp ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/avp ]]; then
    echo -e "Aliens versus Predator already installed.\n"
    uninstall
    exit 1
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/avp.desktop ]]; then
        cat <<EOF >~/.local/share/applications/avp.desktop
[Desktop Entry]
Name=Aliens versus Predator
Exec=${INSTALL_DIR}/avp/avp -f
Icon=${INSTALL_DIR}/avp/avp.ico
Path=${INSTALL_DIR}/avp/
Type=Application
Comment=Offers three separate campaigns, each playable as a separate species: Alien, Predator, or human Colonial Marine.
Categories=Game;ActionGame;
EOF
    fi
}

post_install() {
    if [[ ! -d "$INSTALL_DIR"/avp/.avp ]]; then
        return 0
    fi

    mv "$INSTALL_DIR"/avp/.avp "$HOME"
}

install() {
    echo -e "\nInstalling Aliens versus Predator (1999 video game), please wait..."
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    post_install
    generate_icon
    echo
    read -p "Do you have an original copy of Aliens versus Predator (1999 video game) (y/N)?: " response
    if [[ $response =~ [Nn] ]]; then
        rm -rf "$INSTALL_DIR"/avp/avp_huds "$INSTALL_DIR"/avp/avp_rifs "$INSTALL_DIR"/avp/fastfile
        echo -e "\nCopy your files with lowew case on $INSTALL_DIR/avp, cd into the game directory and type ./avp -f (f for full screen)"
        exit_message
    else
        echo -e "\nType in a terminal $INSTALL_DIR/avp/avp or go to Menu > Games > Aliens versus Predator."
        runme
    fi
}

echo "Install Aliens versus Predator"
echo "=============================="
echo
echo " · Compiled for Raspberry Pi 4."
echo " · Install path: $INSTALL_DIR/avp"
echo " · Very buggy, but playable. Common issue: al lib alc_cleanup 1 device not closed."
echo " · This version has no videos (DRM protected) and no ripped CD audio."
echo " · I've added my custom keyboard WSAD standard, because it's very difficult to change it."
echo " · Full Screen: [CTRL] + [ENTER] | Grab mouse in windowed mode: [CTRL] + [G]"
echo
read -p "Press [Enter] to continue..."

install
