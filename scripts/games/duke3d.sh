#!/bin/bash
#
# Description : Duke Nukem 3D
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.2 (30/Nov/25)
# Tested      : Raspberry Pi 5
#
# Help		  : https://github.com/nukeykt/NBlood <-- Better than duke3d official port for the Pi?
# 			  : http://wiki.duke3d.com/wiki/Building_duke3d_on_Linux#Prerequisites_for_the_build
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
. ../helper.sh || . ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly BINARY_URL="https://misapuntesde.com/rpi_share/eduke32.tar.gz"
readonly BINARY_64_BITS_URL="https://media.githubusercontent.com/media/jmcerrejon/pikiss-bin/refs/heads/main/games/duke3d-20240303-9-g87e7a5e-rpi-aarch64.tar.gz"
readonly PACKAGES=(p7zip)
readonly PACKAGES_DEV=(build-essential nasm libgl1-mesa-dev libglu1-mesa-dev libsdl1.2-dev libsdl-mixer1.2-dev libsdl2-dev libsdl2-mixer-dev flac libflac-dev libvorbis-dev libvpx-dev libgtk2.0-dev freepats)
readonly SOURCE_CODE_URL="https://github.com/jonof/jfduke3d"
readonly VAR_DATA_NAME="DUKE_ATOM"
DATA_URL="http://hendricks266.duke4.net/files/3dduke13_data.7z"
INPUT=/tmp/duke3d.$$


runme() {
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/duke3d && ./duke3d
    echo
    exit_message
}

uninstall() {
    read -p "Do you want to uninstall Duke Nukem 3D (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR"/duke3d ~/.local/share/applications/duke3d.desktop
        if [[ -e "$INSTALL_DIR"/duke3d ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/duke3d ]]; then
    echo -e "Duke Nukem 3D already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/duke3d.desktop ]]; then
        cat <<EOF >~/.local/share/applications/duke3d.desktop
[Desktop Entry]
Name=Duke Nukem 3D
Exec=${PWD}/duke3d/duke3d
Icon=${PWD}/duke3d/icon.png
Type=Application
Comment=Duke Nukem 3D is fps game developed by 3D Realms in 1996.
Categories=Game;ActionGame;
Path=${PWD}/duke3d/
EOF
    fi
}

download_data_files() {
    cd "$INSTALL_DIR/duke3d" || exit 1
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$DATA_URL" "$INSTALL_DIR"/duke3d
}

compile() {
    echo -e "\nInstalling dependencies (if proceed)...\n"
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME"/sc && cd "$_" || exit 1
    git clone "$SOURCE_CODE_URL" duke3d && cd "$_" || exit 1
    echo -e "\n\nCompiling... Estimated time on RPi 4: <10 min.\n"
    make_with_all_cores WITHOUT_GTK=1 USE_LIBVPX=0 HAVE_FLAC=0 RENDERTYPESDL=1 HAVE_JWZGLES=1 OPTLEVEL=0
    echo -e "\nDone.\n"
    exit_message
}

download_binaries() {
    local INSTALL_URL=$BINARY_URL
    echo -e "\nInstalling binary files. If you don't provide game data file inside res/magic-air-copy-pikiss.txt, shareware version will be installed."
    if is_userspace_64_bits; then
        INSTALL_URL=$BINARY_64_BITS_URL
    fi
    download_and_extract "$INSTALL_URL" "$INSTALL_DIR"
}

install() {
    echo -e "\n\nInstalling, please wait..."
    mkdir -p "$INSTALL_DIR" && cd "$_" || exit 1
    download_binaries
    generate_icon
    if exists_magic_file; then
        DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME")
        message_magic_air_copy "$VAR_DATA_NAME"
    fi

    download_data_files
    echo -e "\nDone!. You can play typing $INSTALL_DIR/duke3d/duke3d or opening the Menu > Games > Duke Nukem 3D.\n"
    runme
}

install_script_message
echo "
Duke Nukem 3D for Raspberry Pi
==============================

· More Info: $SOURCE_CODE_URL
· Install path: $INSTALL_DIR/duke3d
· You need the game data files. Shareware version will be installed if you don't provide them.
· If you want to play with the original game data files, copy them to $INSTALL_DIR/duke3d
"
read -p "Press [ENTER] to continue..."
install
