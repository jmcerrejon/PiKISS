#!/bin/bash
#
# Description : fheroes2
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.3 (04/Dec/21)
# Compatible  : Raspberry Pi 4
# Repository  : https://github.com/ihhub/fheroes2
#
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(fluidr3mono-gm-soundfont fluid-soundfont-gm libsdl2-mixer-2.0-0 libsdl2-image-2.0-0 libsdl2-ttf-2.0-0)
readonly PACKAGES_DEV=(libsdl2-dev libsdl2-ttf-dev libsdl2-mixer-dev libsdl2-image-dev gettext)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/fheroes2_0.83_rpi.tar.gz"
readonly SOURCE_CODE_URL="https://github.com/ihhub/fheroes2"
readonly VAR_DATA_NAME="HEROES_2"
INPUT=/tmp/temp.$$

runme() {
    if [ ! -f "$INSTALL_DIR"/fheroes2/fheroes2 ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/fheroes2 && ./fheroes2
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/fheroes2 ~/.local/share/applications/fheroes2.desktop ~/.fheroes2
}

uninstall() {
    read -p "Do you want to uninstall Heroes of Might and Magic II (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/fheroes2 ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/fheroes2 ]]; then
    echo -e "Heroes of Might and Magic II already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/fheroes2.desktop ]]; then
        cat <<EOF >~/.local/share/applications/fheroes2.desktop
[Desktop Entry]
Name=Heroes of Might and Magic II engine (fheroes2)
Version=1.0
Type=Application
Comment=Free implementation of Heroes of Might and Magic II engine
Exec=${INSTALL_DIR}/fheroes2/fheroes2
Icon=${INSTALL_DIR}/fheroes2/icon.png
Path=${INSTALL_DIR}/fheroes2/
Terminal=false
Categories=Game;
EOF
    fi
}

end_message() {
    echo -e "\nDone!. You can play typing $INSTALL_DIR/fheroes2/fheroes2 or opening the Menu > Games > Heroes of Might and Magic II engine (fheroes2).\n"
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    git clone "$SOURCE_CODE_URL" fheroes2 && "$_"
    time export WITH_SDL2="ON" make -j"$(nproc)"
    make_install_compiled_app
    echo -e "\nDone!. Check the code at $HOME/sc/fheroes2."
    exit_message
}

get_demo() {
    echo -e "\nInstalling demo files...\n"
    cd "$INSTALL_DIR/fheroes2/script/demo" || exit 1
    ./demo_linux.sh
}

download_data_files() {
    DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME")
    message_magic_air_copy "$VAR_DATA_NAME"
    download_and_extract "$DATA_URL" "$INSTALL_DIR/fheroes2"
}

install() {
    local DATA_URL
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    generate_icon
    if ! exists_magic_file; then
        get_demo
        end_message
        runme
    fi

    download_data_files
    end_message
    runme
}

install_script_message
echo "
Heroes of Might and Magic II engine (fheroes2) for Raspberry Pi
===============================================================

 · Free implementation of Heroes of Might and Magic II engine.
 · F4: Full screen.
 · Still in heavy development, but playable.
 · If you don't provide game data files inside res/magic-air-copy-pikiss.txt, demo will be installed.
"
read -p "Press [Enter] to continue..."

install
