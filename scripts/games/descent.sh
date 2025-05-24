#!/bin/bash
#
# Description : Descent 1 & 2
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.0 (11/Feb/24)
# Tested      : Raspberry Pi 5
# TODO        : Add Full version using magic-air-copy-pikiss.txt
#
# HELP	      : https://github.com/dxx-rebirth/dxx-rebirth
#               https://github.com/dxx-rebirth/dxx-rebirth/blob/master/INSTALL.markdown
#               https://github.com/JeodC/PortMaster-Descent/tree/main/addons
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libphysfs1 libglu1-mesa)
readonly PACKAGES_DEV=(libsdl1.2-dev libsdl-mixer1.2-dev libphysfs-dev libsdl2-image-dev scons libsdl2-net-dev libsdl-image1.2-dev)
readonly DXX_URL="https://misapuntesde.com/rpi_share/dxx-rebirth.tar.gz"
readonly DXX_64_BIT_URL="https://misapuntesde.com/rpi_share/dxx-rebirth-0.60-rpi-aarm64.tar.gz"
readonly DXX_DATA_DIRECTORY_URL="https://misapuntesde.com/rpi_share/descent12-hq-data.tar.gz"
readonly SOURCE_CODE_URL="https://github.com/dxx-rebirth/dxx-rebirth"

uninstall() {
    echo
    read -p "Do you want to uninstall Descent Rebirth (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf ~/.local/share/applications/d1x.desktop ~/.local/share/applications/d2x.desktop ~/.d1x-rebirth ~/.d2x-rebirth
        [[ -e $INSTALL_DIR/descent ]] && sudo rm -rf "$INSTALL_DIR/descent"
        if [[ -e $INSTALL_DIR/descent ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -e $INSTALL_DIR/descent ]]; then
    echo "Warning!: Descent Rebirth already installed."
    uninstall
fi

generate_icon_d1x() {
    if [[ ! -e ~/.local/share/applications/d1x.desktop ]]; then
        cat <<EOF >~/.local/share/applications/d1x.desktop
[Desktop Entry]
Name=Descent 1
Exec=${INSTALL_DIR}/descent/d1x-rebirth -hogdir ${INSTALL_DIR}/descent/data
Icon=${INSTALL_DIR}/descent/d1x-rebirth.png
Type=Application
Comment=The game requires the player to navigate labyrinthine mines while fighting virus-infected robots.
Categories=Game;ActionGame;
EOF
    fi
}

generate_icon_d2x() {
    if [[ ! -e ~/.local/share/applications/d2x.desktop ]]; then
        cat <<EOF >~/.local/share/applications/d2x.desktop
[Desktop Entry]
Name=Descent 2
Exec=${INSTALL_DIR}/descent/d2x-rebirth -hogdir ${INSTALL_DIR}/descent/data
Icon=${INSTALL_DIR}/descent/d2x-rebirth.png
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
    echo -e "\nCompiling... Estimated ~5 minutes. Please wait...\n"
    time nice scons -j"$(nproc)" raspberrypi=mesa sdl2=1 lto=1 sdlmixer=1 e_editor=1
    echo "Done!. Go to $HOME/sc/descent"
    exit_message
}

post_install() {
    # Some extra addons to improve the game experience ;)
    echo -e "\nInstalling HIGH music/textures quality pack...\n\nPlease wait..."
    download_and_extract "$DXX_DATA_DIRECTORY_URL" "$INSTALL_DIR/descent"
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    if is_kernel_64_bits; then
        download_and_extract "$DXX_64_BIT_URL" "$INSTALL_DIR"
    else
        download_and_extract "$DXX_URL" "$INSTALL_DIR"
    fi
    post_install
    generate_icon_d1x
    generate_icon_d2x
    echo -e "\nDone!. Type to play $INSTALL_DIR/descent/d1x-rebirth or $INSTALL_DIR/descent/d2x-rebirth or opening the Menu > Games > Descent 1 or 2."
    exit_message
}

install_script_message
echo "
Descent DXX-Rebirth
===================

· Compiled & optimized using Link Time Optimization (LTO) for SDL2.
· Add High quality texture & sound pack (Soundtrack in OGG format - SC-55 Version).
· Using the shareware version. You are free to copy the full version inside $INSTALL_DIR/descent

Installing, please wait...
"

install
