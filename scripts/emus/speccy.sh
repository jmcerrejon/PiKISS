#!/bin/bash
#
# Description : Portable ZX-Spectrum emulator
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.6.0 (01/Oct/24)
# Tested      : Raspberry 5
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libcogl20 libsdl2-2.0-0)
readonly PACKAGES_DEV=(libcurl4-gnutls-dev libcogl20 libsdl2-dev)
readonly URL_FILE="https://misapuntesde.com/rpi_share/unreal_speccy_portable_rpi.tar.gz"
readonly WEBSITE_URL="https://bitbucket.org/djdron/unrealspeccyp"

run() {
    if [[ -f "$INSTALL_DIR"/speccy/ninjajar.tap ]]; then
        read -p "Do you want to play NinJAJAR? (y/N) " response
        if [[ $response =~ [Nn] ]]; then
            exit_message
        fi
        cd "$INSTALL_DIR"/speccy || exit 1
        if [ "$(getconf LONG_BIT)" == "64" ]; then
            ./usp.aarch64 ninjajar.tap
        else
            ./usp.armhf ninjajar.tap
        fi
    fi
    exit_message
}

uninstall() {
    echo
    read -p "Do you want to uninstall Unreal Speccy Emulator (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf ~/.local/share/applications/speccy.desktop ~/.usp
        [[ -e $INSTALL_DIR/speccy ]] && sudo rm -rf "$INSTALL_DIR/speccy"
        if [[ -e $INSTALL_DIR/speccy ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -e $INSTALL_DIR/speccy ]]; then
    echo "Warning!: Unreal Speccy Emulator already installed."
    uninstall
fi

generate_icon() {
    if [[ ! -e ~/.local/share/applications/speccy.desktop ]]; then
        echo "Creating shortcut...\n"
        sudo wget https://quantum-bits.org/tango/icons/computer-sinclair-zx-spectrum.png -O /usr/share/pixmaps/spectrum.png
        cat <<EOF >~/.local/share/applications/speccy.desktop
[Desktop Entry]
Name=Speccy (ZX Spectrum)
Comment=Speccy emulates some versions of Sinclair ZX Spectrum.
Exec=$INSTALL_DIR/speccy/run.sh
Icon=/usr/share/pixmaps/spectrum.png
Terminal=false
Type=Application
Categories=Application;Game;
Path=$INSTALL_DIR/speccy
EOF
    fi
}

install() {
    echo -e "\nInstalling, please wait...\n"
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$URL_FILE" "$INSTALL_DIR"
    generate_icon
    echo -e "\nDone!. To play go to Menu > Games > Speccy or cd $INSTALL_DIR/speccy and type: ./run.sh\n"
    run
}

compile_speccy() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    git clone https://bitbucket.org/djdron/unrealspeccyp.git usp && cd usp/build/cmake || exit 1
    cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DUSE_SDL=Off -DUSE_SDL2=On -DSDL2_INCLUDE_DIRS="/usr/inlude" -DCMAKE_CXX_FLAGS="$(sdl2-config --cflags)" -DCMAKE_EXE_LINKER_FLAGS="$(sdl2-config --libs)" -Wno-dev
    make_with_all_cores
    echo -e "\nDone!."
    exit_message
}

install_script_message
echo "
Portable ZX-Spectrum emulator (unrealspeccyp)
=============================================

 · ESC to enter menu
 · Add Ninjajar by Mojon Twins.
 · More info: $WEBSITE_URL"

install
