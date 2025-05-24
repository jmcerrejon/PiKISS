#!/bin/bash
#
# Description : OpenMSX emulator
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.5.2 (19/Nov/23)
# Tested      : Raspberry 5
#
# shellcheck disable=SC1091
. ../helper.sh || . ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }
clear

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libglew2.2 libsdl2-ttf-2.0-0)
readonly PACKAGES_DEV=(libsdl2-dev libsdl2-ttf-dev libglew-dev libao-dev libogg-dev libtheora-dev libxml2-dev libvorbis-dev tcl-dev g++-4.8)
readonly SOURCE_CODE_URL="https://github.com/openMSX/openMSX/releases/download/RELEASE_18_0/openmsx-18.0.tar.gz"
readonly BINARY_ARMHF_URL="https://misapuntesde.com/rpi_share/openmsx_0.18_armhf.tar.gz"
readonly BINARY_AARCH64_URL="https://misapuntesde.com/rpi_share/openmsx_0.18_aarch64.tar.gz"
readonly RELEASE_NOTES_URL="https://raw.githubusercontent.com/openMSX/openMSX/RELEASE_18_0/doc/release-notes.txt"
readonly SETTINGS_URL="https://raw.githubusercontent.com/jmcerrejon/PiKISS/master/res/settings.xml"
readonly ROM_GAME_URL="http://www.retroworks.es/upload/Mutants%20from%20the%20deep.zip"
readonly SYSTEMROMS_URL="http://www.msxarchive.nl/pub/msx/emulator/openMSX/systemroms.zip"
readonly SYSTEMROMS="$HOME/.openMSX/share/systemroms"

runme() {
    echo
    if [[ -f "$HOME/.openMSX/share/software/Mutants from the deep.rom" ]]; then
        read -p "Do you want to play Mutants from the Deep now? [y/n] " option
        case "$option" in
        y*) cd "$INSTALL_DIR"/openMSX/bin/ && ./openmsx "$HOME/.openMSX/share/software/Mutants from the deep.rom" ;;
        esac
    fi
}

uninstall() {
    read -p "Do you want to uninstall OpenMSX (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo rm -rf "$INSTALL_DIR"/openMSX ~/.openMSX ~/.local/share/applications/openmsx.desktop
        if [[ -e "$INSTALL_DIR"/openMSX ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/openMSX ]]; then
    echo -e "OpenMSX already installed.\n"
    uninstall
    exit 1
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/openmsx.desktop ]]; then
        cat <<EOF >~/.local/share/applications/openmsx.desktop
[Desktop Entry]
Name=OpenMSX
Exec=${INSTALL_DIR}/openMSX/bin/openmsx
Icon=${INSTALL_DIR}/openMSX/logo.ico
Path=${INSTALL_DIR}/openMSX
Type=Application
Comment=OpenMSX is an emulator for the MSX home computer system. Its goal is to emulate all aspects of the MSX with 100% accuracy: perfection in emulation.
Categories=Game;
EOF
    fi
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    echo "Downloading and compiling OpenMSX, estimated time ~57 minutes on RPi 4, so be patience..."
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    download_and_extract "$SOURCE_CODE_URL" "$HOME/sc"
    cd openmsx* || exit 1
    ./configure
    make_with_all_cores
    make_install_compiled_app
    read -p "Do you want to install some extras (system ROMs,...) (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        postinstall
    fi
}

download_game() {
    echo -e "\nDownloading game..."
    download_and_extract "$ROM_GAME_URL" "$HOME/.openMSX/share/software"
}

fix_libGLEW() {
    local -r libGLEW_21_PATH="/usr/lib/arm-linux-gnueabihf/libGLEW.so.2.1"
    local -r libGLEW_22_PATH="/usr/lib/arm-linux-gnueabihf/libGLEW.so.2.2"

    if [[ ! -f $libGLEW_21_PATH ]]; then
        echo -e "\nFixing libGLEW..."
        sudo ln -sf "$libGLEW_22_PATH" "$libGLEW_21_PATH"
    fi
}

postinstall() {
    echo -e "\nInstalling ROM BiOS for maximum compatibility..."
    download_and_extract "$SYSTEMROMS_URL" "$SYSTEMROMS/.openMSX"
    wget -q "$SETTINGS_URL" "$HOME"/.openMSX/share/settings.xml

    fix_libGLEW
    download_game
    runme
}

install() {
    local BINARY_URL
    BINARY_URL=$BINARY_ARMHF_URL

    if is_userspace_64_bits; then
        BINARY_URL=$BINARY_AARCH64_URL
    fi

    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR/openMSX" || exit 1
    [[ ! -d $HOME/.openMSX ]] && mkdir -p "$HOME/.openMSX" || exit 1
    mv share "$HOME/.openMSX"
    generate_icon
    postinstall
    exit_message
}

install_script_message
echo "
OpenMSX
=======

· More Info: http://openmsx.org/ | $RELEASE_NOTES_URL
· Tweaked settings.
· Extra: System ROMs.
· Game included (Thanks to @Locomalito): Terror From The Deep.
· Get more games at https://www.msxdev.org/
· Install path: $INSTALL_DIR/openmsx
"

install
