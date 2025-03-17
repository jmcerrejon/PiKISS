#!/bin/bash
#
# Description : Fallout 1/2 Community Ed
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.4 (17/Mar/25)
# Tested      : Raspberry Pi 5
# TODO        : Fallout 1 support
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }
clear

INSTALL_DIR="$HOME/games"
PACKAGES=(libstdc++6 libc6)
PACKAGES_DEV=(cmake libsdl2-2.0-0 g++)
BINARY_URL="https://misapuntesde.com/rpi_share/fallout2-ce-rpi-all.tar.gz"
SOURCE_CODE_URL="https://github.com/alexbatalov/fallout2-ce"
readonly VAR_DATA_NAME_1="FALLOUT"
readonly VAR_DATA_NAME_2="FALLOUT2"

runme() {
    echo
    read -p "Do you want to play Fallout 2 now? [y/n] " option
    case "$option" in
    y*) cd "$INSTALL_DIR"/fallout2-ce && ./run.sh ;;
    esac
    exit_message
}

uninstall() {
    read -p "Do you want to uninstall Fallout 2 (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR/fallout2-ce" ~/.config/fallout2-ce ~/.local/share/applications/fallout2-ce.desktop
        if [[ -e $INSTALL_DIR/fallout2-ce ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d $INSTALL_DIR/fallout2-ce ]]; then
    echo -e "Fallout 2 already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\n\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/fallout2-ce.desktop ]]; then
        cat <<EOF >~/.local/share/applications/fallout2-ce.desktop
[Desktop Entry]
Name=Fallout 2 Community Ed
Exec=${INSTALL_DIR}/fallout2-ce/run.sh
Icon=${INSTALL_DIR}/fallout2-ce/fallout2.ico
Path=${INSTALL_DIR}/fallout2-ce
Type=Application
Comment=Fallout 2: A Post Nuclear Role Playing Game is the sequel to the original Fallout.
Categories=Game;ActionGame;
EOF
    fi
}

compile() {
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    git clone "$SOURCE_CODE_URL" fallout2-ce && cd "$_" || exit 1
    echo -e "\nCompiling...\n"
    export CFLAGS="-O3 -march=armv8-a+crc -mtune=cortex-a72" && export CPPFLAGS="$CFLAGS" && export CXXFLAGS="$CFLAGS"

    cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo
    make_with_all_cores
    echo -e "\nDone!."
    exit_message
}

install_full_fallout() {
    local FALLOUT_DIR="$INSTALL_DIR/fallout-ce"
    local DATA_URL
    DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME_1")

    if exists_magic_file; then
        message_magic_air_copy "$VAR_DATA_NAME_1"
        download_and_extract "$DATA_URL" "$FALLOUT_DIR"
    fi
}

install_full_fallout2() {
    local FALLOUT_DIR2="$INSTALL_DIR/fallout2-ce"
    local DATA_URL
    DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME_2")

    if exists_magic_file; then
        message_magic_air_copy "$VAR_DATA_NAME_2"
        download_and_extract "$DATA_URL" "$FALLOUT_DIR2"
    fi
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    echo -e "\nInstalling, please wait..."

    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    generate_icon
    install_full_fallout2
    echo -e "\n\nDone!. You can play opening the Menu > Games > Fallout 2 Community Ed.\n"
    runme
}

install_script_message
echo "
Fallout 2 Community Edition
===========================

· Install path: $INSTALL_DIR/fallout2-ce
· Copy the content of the game inside $INSTALL_DIR/fallout2-ce
"

read -p "Do you want to continue? (y/N) " response
if [[ $response =~ [Nn] ]]; then
    exit_message
fi

install
