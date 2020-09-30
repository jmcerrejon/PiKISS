#!/bin/bash
#
# Description : ResidualVM Engine
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.3 (30/Sep/20)
# Compatible  : Raspberry Pi 4 (tested)
#
# Help		  : https://wiki.residualvm.org/index.php/Building_ResidualVM
#				https://tljhd.github.io/
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly COMPILE_DIR="$HOME/sc"
readonly PACKAGES=( libSDL2-net-2.0-0 libglu1-mesa libglew2.1 )
readonly PACKAGES_DEV=( libsdl1.2-dev libglew-dev libjpeg-dev libclanlib-dev libmpeg2-4-dev )
readonly BINARY_PATH="https://srv-file21.gofile.io/downloadStore/srv-store2/I6hN2d/residualvm_rpi.tar.gz"
readonly SOURCE_PATH="https://github.com/residualvm/residualvm.git"

runme() {
    echo
    if [ ! -f "$INSTALL_DIR"/residualvm/residualvm ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/residualvm && ./residualvm
    clear
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/residualvm ~/.config/residualvm
}

uninstall() {
    read -p "Do you want to uninstall ResidualVM (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/residualvm ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/residualvm ]]; then
    echo -e "ResidualVM already installed.\n"
    uninstall
    exit 1
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/residualvm.desktop ]]; then
        cat <<EOF >~/.local/share/applications/residualvm.desktop
[Desktop Entry]
Name=ResidualVM
Exec=/home/pi/games/residualvm/residualvm
Icon=/home/pi/games/residualvm/residualvm.ico
Path=/home/pi/games/residualvm/
Type=Application
Comment=ResidualVM is a cross-platform 3D game interpreter which allows you to play Lua-based 3D adventures
Categories=Game;ActionGame;
EOF
    fi
}

install() {
    local CFG_DIR
    CFG_DIR="$HOME/.config/residualvm"
    echo -e "\nInstalling, please wait..."
    installPackagesIfMissing "${PACKAGES[@]}"
    download_and_extract "$BINARY_PATH" "$INSTALL_DIR"
    if [ ! -d "$CFG_DIR" ]; then
        mkdir -p "$CFG_DIR"
        cp "$INSTALL_DIR"/residualvm/residualvm.ini "$CFG_DIR"
    fi
    generate_icon
    echo -e "\nType in a terminal $INSTALL_DIR/residualvm/residualvm or go to Menu > Games > ResidualVM."
}

compile() {
    echo -e "Compiling, please wait...\n"
    installPackagesIfMissing "${PACKAGES_DEV[@]}"
    mkdir -p "$COMPILE_DIR" && cd "$_"
    if [ ! -d ~/sc/residualvm ]; then
        git clone "$SOURCE_PATH" residualvm
    fi
    cd ~/sc/residualvm
    mkdir -p build && cd "$_"
    make clean
    ../configure
    make_with_all_cores
    echo -e "\nDone!. cd $COMPILE_DIR/residualvm/build to get the binary."
    exit_message
}

echo "ResidualVM"
echo "=========="
echo
echo "· More Info: https://www.residualvm.org or https://github.com/residualvm/residualvm"
echo "· Demo games included: The Longest Journey & Escape from Monkey Island"
echo "· NOTE: [CTRL] + F5 = Menu inside a game."
echo "· Install path: $INSTALL_DIR/residualvm"

install
runme