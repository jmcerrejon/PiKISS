#!/bin/bash
#
# Description : Temptations
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (06/Dec/20)
# Compatible  : Raspberry Pi 4
# Repository  : https://github.com/pipagerardo/temptations
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libsdl2-image-2.0-0 libsdl2-mixer-2.0-0)
readonly PACKAGES_DEV=(libsdl2-dev libsdl2-mixer-dev libsdl2-image-dev)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/temptations-rpi.tar.gz"
readonly SOURCE_CODE_URL="https://github.com/pipagerardo/temptations"

runme() {
    echo
    if [ ! -f "$INSTALL_DIR"/temptations/temptations ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run..."
    cd "$INSTALL_DIR"/temptations && ./temptations
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/temptations ~/.local/share/applications/temptations.desktop
}

uninstall() {
    read -p "Do you want to uninstall Temptations (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/temptations ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/temptations ]]; then
    echo -e "Temptations already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/temptations.desktop ]]; then
        cat <<EOF >~/.local/share/applications/temptations.desktop
[Desktop Entry]
Name=Temptations
Type=Application
Comment=Temptations is a platform game made by the Spanish company Topo Soft in 1988 exclusively for MSX computers
Exec=${INSTALL_DIR}/temptations/temptations
Icon=${INSTALL_DIR}/temptations/temptations.ico
Path=${INSTALL_DIR}/temptations/
Terminal=false
Categories=Game;
EOF
    fi
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || return
    git clone "$SOURCE_CODE_URL" temptations && cd "$_"/desktop_version || return
    cd build || return
    cmake -G 'Unix Makefiles' -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_CXX_FLAGS="$(sdl2-config --cflags)" -DCMAKE_EXE_LINKER_FLAGS="$(sdl2-config --libs)" ..
    make_with_all_cores
    cp temptations ../bin
    echo -e "\nDone!. Check the code at $HOME/sc/temptations/bin"
    exit_message
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    generate_icon
    echo -e "\n\nDone!. You can play typing $INSTALL_DIR/temptations/temptations or opening the Menu > Games > Temptations."
    runme
}

install_script_message
echo "
Temptations for Raspberry Pi
============================

 · PDF guide inside $INSTALL_DIR/temptations (with extra directory).
 · Thanks Gerardo Herce for this enhanced version for one of the best MSX games.
 · F11 - Switches between Window and Full Screen.
 · G - Switches graphics between MSX Original and Nene Franz's new one.
 · L - Switches between Spanish and English language.
 · M - Switches Music off or on.
 · P - Pause.
"
read -p "Press [Enter] to continue..."

install