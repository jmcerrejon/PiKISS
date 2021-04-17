#!/bin/bash
#
# Description : Descent 1 & 2 thks to DXX-Rebirth v0.61.0 0.60.0-beta2-544-g427f45fdd703 compiled on 17/Sep/2019
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.4 (17/APr/21)
# Compatible  : Raspberry Pi 1-4 (tested on Raspberry Pi 4)
# TODO        : Add Full version using magic-air-copy-pikiss.txt
#
# HELP	      : https://github.com/dxx-rebirth/dxx-rebirth
#				https://github.com/dxx-rebirth/dxx-rebirth/blob/master/INSTALL.markdown
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libphysfs1 libglu1-mesa)
readonly PACKAGES_DEV=(libsdl1.2-dev libsdl-mixer1.2-dev libphysfs-dev libsdl2-image-dev scons libsdl2-net-dev)
readonly SOURCE_CODE_URL="https://github.com/dxx-rebirth/dxx-rebirth"
readonly D1X_SHARE_URL="https://www.dxx-rebirth.com/download/dxx/content/descent-pc-shareware.zip"
readonly D2X_SHARE_URL="https://www.dxx-rebirth.com/download/dxx/content/descent2-pc-demo.zip"
readonly DXX_URL="https://misapuntesde.com/rpi_share/dxx-rebirth.tar.gz"
readonly D1X_HIGH_TEXTURE_URL="https://www.dxx-rebirth.com/download/dxx/res/d1xr-hires.dxa"
readonly D1X_OGG_URL="https://www.dxx-rebirth.com/download/dxx/res/d1xr-sc55-music.dxa"
readonly D2X_OGG_URL="https://www.dxx-rebirth.com/download/dxx/res/d2xr-sc55-music.dxa"
readonly D1X_DATA="$HOME/.d1x-rebirth/Data"
readonly D2X_DATA="$HOME/.d2x-rebirth/Data"
#readonly INSTALL_DIR="/usr/games"

uninstall() {
    echo
    read -p "Do you want to uninstall Descent Rebirth (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        [[ -d $D1X_DATA ]] && rm -rf "$D1X_DATA" ~/.local/share/applications/d1x.desktop
        [[ -d $D2X_DATA ]] && rm -rf "$D2X_DATA" ~/.local/share/applications/d2x.desktop
        [[ -e $INSTALL_DIR/descent/d1x-rebirth ]] && sudo rm "$INSTALL_DIR/descent/d1x-rebirth"
        [[ -e $INSTALL_DIR/descent/d2x-rebirth ]] && sudo rm "$INSTALL_DIR/descent/d2x-rebirth"
        if [[ -e $INSTALL_DIR/descent/d1x-rebirth ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -e $INSTALL_DIR/descent/d1x-rebirth ]]; then
    echo "Warning!: Descent Rebirth already installed."
    uninstall
fi

generateIconsD1X() {
    if [[ ! -e ~/.local/share/applications/d1x.desktop ]]; then
        cat <<EOF >~/.local/share/applications/d1x.desktop
[Desktop Entry]
Name=Descent 1
Exec=${INSTALL_DIR}/descent/d1x-rebirth
Icon=${INSTALL_DIR}/descent/descent.png
Type=Application
Comment=The game requires the player to navigate labyrinthine mines while fighting virus-infected robots.
Categories=Game;ActionGame;
EOF
    fi
}

generateIconsD2X() {
    if [[ ! -e ~/.local/share/applications/d2x.desktop ]]; then
        cat <<EOF >~/.local/share/applications/d2x.desktop
[Desktop Entry]
Name=Descent 2
Exec=${INSTALL_DIR}/descent/d2x-rebirth
Icon=${INSTALL_DIR}/descent/descent2.png
Type=Application
Comment=Complete 24 levels where different types of AI-controlled robots will try to destroy you.
Categories=Game;ActionGame;
EOF
    fi
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    git clone "$SOURCE_CODE_URL" descent && cd "$_" || exit 1
    scons
    # compress with tar -czvf ~/dxx-rebirth.tar.gz d1x-rebirth d2x-rebirth
    echo "Done!. Go to $HOME/sc/descent"
    exit_message
}

post_install() {
    # Some extra addons to improve the game experience ;)
    clear && echo -e "\nInstalling HIGH textures quality pack...\n\nPlease wait...\n" && sudo wget -P "$D1X_DATA" $D1X_HIGH_TEXTURE_URL
    echo -e "\n\nInstalling OGG Music for better experience...\n\n· All music was recorded with the Roland Sound Canvas SC-55 MIDI Module.\n\nPlease wait...\n" && sudo wget -P "$D1X_DATA" $D1X_OGG_URL && sudo wget -P "$D2X_DATA" $D2X_OGG_URL
    # Cleaning da house
    sudo rm "$INSTALL_DIR"/dxx-rebirth.tar.gz "$D1X_DATA"/descent-pc-shareware.zip "$D2X_DATA"/descent2-pc-demo.zip
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    # Binaries
    download_and_extract "$DXX_URL" "$INSTALL_DIR"
    # Shareware demo datas
    download_and_extract "$D1X_SHARE_URL" "$D1X_DATA"
    download_and_extract "$D2X_SHARE_URL" "$D2X_DATA"
    #post_install
    generateIconsD1X
    generateIconsD2X
    echo -e "\nDone!. Type to play $INSTALL_DIR/descent/d1x-rebirth or $INSTALL_DIR/descent/d2x-rebirth or opening the Menu > Games > Descent 1 or 2."
    exit_message
}

install_script_message
echo "
Descent DXX-Rebirth
===================

· Add High quality texture pack.
· Add High quality sound pack.
· This is using the shareware version. You are free to copy the full version inside $INSTALL_DIR/descent

Installing, please wait...
"

install
