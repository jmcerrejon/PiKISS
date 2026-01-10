#!/bin/bash
#
# Description : OpenJK
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 2.0.1 (26/Dec/25)
# Tested      : Raspberry Pi 5
#
# shellcheck disable=SC1091
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libpng16-16 libjpeg-dev zlib1g-dev)
readonly PACKAGES_DEV=(build-essential cmake libjpeg-dev libpng-dev zlib1g-dev libsdl2-dev)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/openjk-rpi.tar.gz"
readonly BINARY_64_BITS_URL="https://media.githubusercontent.com/media/jmcerrejon/pikiss-bin/refs/heads/main/games/OpenJK-linux-arm64.tar.gz"
readonly SOURCE_CODE_URL="https://github.com/JACoders/OpenJK.git"
readonly VAR_DATA_NAME="JEDI_ACADEMY"
readonly CODENAME=$(get_codename)

runme() {
    if [ ! -f "$INSTALL_DIR"/JediAcademy/openjk_sp.arm ] && [ ! -f "$INSTALL_DIR"/JediAcademy/openjk_sp.arm64 ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/JediAcademy || exit 1
    ./openjk_sp.arm || ./openjk_sp.arm64
    exit_message
}

uninstall() {
    read -p "Do you want to uninstall OpenJK (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR"/JediAcademy ~/.local/share/applications/JediAcademy.desktop ~/.local/share/applications/JediAcademySP.desktop ~/.local/share/openjk
        if [[ -e "$INSTALL_DIR"/JediAcademy ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/JediAcademy ]]; then
    echo -e "OpenJK already installed.\n"
    uninstall
fi

generate_icons() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/JediAcademy.desktop ]]; then
        cat <<EOF >~/.local/share/applications/JediAcademy.desktop
[Desktop Entry]
Name=OpenJK (Multiplayer)
Exec=${INSTALL_DIR}/JediAcademy/openjk.arm64
Icon=${INSTALL_DIR}/JediAcademy/icons/OpenJK_Icon_32.png
Path=${INSTALL_DIR}/JediAcademy/
Type=Application
Comment=Community effort to maintain and improve Jedi Academy (SP & MP) released by Raven Software
Categories=Game;ActionGame;
EOF
    fi

    if [[ ! -e ~/.local/share/applications/JediAcademySP.desktop ]]; then
        cat <<EOF >~/.local/share/applications/JediAcademySP.desktop
[Desktop Entry]
Name=OpenJK (Single Player)
Exec=${INSTALL_DIR}/JediAcademy/openjk_sp.arm64
Icon=${INSTALL_DIR}/JediAcademy/icons/OpenJK_Icon_32.png
Path=${INSTALL_DIR}/JediAcademy/
Type=Application
Comment=Community effort to maintain and improve Jedi Academy (SP & MP) released by Raven Software
Categories=Game;ActionGame;
EOF
    fi
}

compile() {
    echo -e "\nInstalling dependencies...\n"
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    git clone "$SOURCE_CODE_URL" openjk && cd "$_" || exit 1

    echo -e "\nCreating build directory..."
    mkdir -p build && cd "$_" || exit 1

    echo -e "\nConfiguring with CMake..."
    cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DUseInternalMiniZip=ON -DUseInternalZlib=ON

    echo -e "\nPatching zlib library files..."
    for file in lib/zlib/gzlib.c lib/zlib/gzread.c lib/zlib/gzwrite.c; do
        if [ -f "../$file" ]; then
            if ! grep -q "#include <unistd.h>" "../$file"; then
                sed -i '1i#include <unistd.h>' "../$file"
            fi
        fi
    done

    echo -e "\nCompiling... Estimated time on RPi 4-5: ~7-10 min.\n"
    make_with_all_cores
    echo -e "\nDone."
    exit_message
}

download_data_files() {
    DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME")
    message_magic_air_copy "$VAR_DATA_NAME"
    download_and_extract "$DATA_URL" "$INSTALL_DIR/JediAcademy/base"
}

install() {
    install_script_message
    echo -e "\n\nInstalling OpenJK, please wait..."
    mkdir -p "$INSTALL_DIR" && cd "$_" || exit 1
    if is_kernel_64_bits; then
        download_and_extract "$BINARY_64_BITS_URL" "$INSTALL_DIR"
    else
        download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    fi
    # mv "$INSTALL_DIR/JediAcademy/openjk" ~/.local/share/
    generate_icons
    if exists_magic_file; then
        download_data_files
        echo -e "\n\nDone!. You can play typing $INSTALL_DIR/JediAcademy/openjk_sp.arm64 or opening the Menu > Games > OpenJK.\n"
        runme
    fi

    echo -e "\nDone. Copy the *.pk3 data files inside $INSTALL_DIR/JediAcademy/base and then, you can play typing $INSTALL_DIR/JediAcademy/openjk_sp.arm64 or opening the Menu > Games > OpenJK"
    open_file_explorer "$INSTALL_DIR/JediAcademy/base"
    exit_message
}

install_script_message
echo "
Jedi Academy (OpenJK)
=====================

 • Install path: $APP_DIR
 • Place your game data in: $APP_DIR/base
   - Example: copy *.pk3 files from your original game installation into that folder.
 • Run:
   - Menu > Games > OpenJK (Single Player or Multiplayer)
   - or: $APP_DIR/openjk_sp.arm64 for Single Player and $APP_DIR/openjk.arm64 for Multiplayer
"

install
