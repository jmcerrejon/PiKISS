#!/bin/bash
#
# Description : Open Claw
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.2 (25/Sep/21)
# Compatible  : Raspberry Pi 4
# Repository  : https://github.com/pjasicek/OpenClaw
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(timidity freepats libsdl2-mixer-2.0-0 libsdl2-ttf-2.0-0 libsdl2-image-2.0-0 libsdl2-gfx-1.0-0)
readonly PACKAGES_DEV=(libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev libsdl2-gfx-dev)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/openclaw-dev-rpi.tar.gz"
readonly DATA_GAME_URL="https://e.pcloud.link/publink/show?code=XZlVm7ZMLLfABLeVofG7dwVcorYsRep7Eq7"
readonly SOURCE_CODE_URL="https://github.com/pjasicek/OpenClaw"

runme() {
    if [ ! -f "$INSTALL_DIR"/openclaw/openclaw ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run..."
    cd "$INSTALL_DIR"/openclaw && ./openclaw
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/openclaw ~/.local/share/applications/openclaw.desktop
}

uninstall() {
    read -p "Do you want to uninstall Open Claw (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/openclaw ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/openclaw ]]; then
    echo -e "Open Claw already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/openclaw.desktop ]]; then
        cat <<EOF >~/.local/share/applications/openclaw.desktop
[Desktop Entry]
Name=Open Claw
Type=Application
Comment=Captain Claw (1997) reimplementation
Exec=${INSTALL_DIR}/openclaw/openclaw
Icon=${INSTALL_DIR}/openclaw/icon.png
Path=${INSTALL_DIR}/openclaw/
Terminal=false
Categories=Game;
EOF
    fi
}

end_message() {
    echo -e "\n\nDone!. You can play typing $INSTALL_DIR/openclaw/openclaw or opening the Menu > Games > Open Claw."
    runme
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || return
    git clone "$SOURCE_CODE_URL" openclaw && cd "$_" || return
    mkdir build && cd "$_" || return
    cmake -G 'Unix Makefiles' -DCMAKE_BUILD_TYPE=RelWithDebInfo .. && cmake ..
    make_with_all_cores
    make_install_compiled_app
    echo -e "\nDone!. Check the code at $HOME/sc/openclaw/Build_Release"
    exit_message
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    download_file "$DATA_GAME_URL" "$INSTALL_DIR/openclaw"
    generate_icon
    end_message
}

install_script_message
echo "
Open Claw for Raspberry Pi
==========================

 · Optimized for Raspberry Pi 4.
 · Current resolution 1280x720, but you can change it editing config.xml
 · The game is in development. Latest level developed: 13.
 · KEYS: Cursors=Movement | CTRL=Sword/Kick | Shift=Change main weapon | ALT=Fire | Space=Jump
"
read -p "Press [Enter] to continue..."

install
