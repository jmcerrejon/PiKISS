#!/bin/bash
#
# Description : PiKISS GUI from Jai-JAP
# Author      : Jai A P (jai.jap.318@gmail.com)
# Version     : 1.0.0 (16/Apr/22)
# Compatible  : Raspberry Pi 1-4
# Repository  : https://github.com/ptitSeb/gl4es
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly COMPILE_PATH="$HOME/sc/pikiss-gui"
readonly PACKAGES_DEV=(ninja-build gobject-introspection libgee-0.8-dev libgirepository1.0-dev libgtk-3-dev valac libgnome-menu-3-dev)
readonly GITHUB_PATH="https://github.com/Jai-JAP/pikiss-gui.git"

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    pip_install meson
    mkdir -p "$HOME"/sc && cd "$_" || exit 1
    if [[ ! -d "$COMPILE_PATH" ]]; then
        echo -e "\nCloning and compiling repo...\n"
        git clone "$GITHUB_PATH" gl4es && cd "$_" || exit 1
    else
        echo -e "\nDirectory already exists. Updating and compiling repo...\n"
        cd "$COMPILE_PATH" || exit 1
        git pull
    fi
    ./build.sh
    echo -e "\nDone!. You can run PiKISS GUI from Menu -> Accessories -> PiKISS GUI"
    exit_message
}

compile
