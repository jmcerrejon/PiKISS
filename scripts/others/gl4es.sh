#!/bin/bash
#
# Description : GL4ES from ptitSeb
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (01/Sep/20)
# Compatible  : Raspberry Pi 1-4
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly COMPILE_PATH="$HOME/sc/gl4es"
readonly PACKAGES_DEV=(libx11-dev)
readonly GITHUB_PATH="https://github.com/ptitSeb/gl4es.git"

compile() {
    installPackagesIfMissing "${PACKAGES_DEV[@]}"

    mkdir -p "$HOME"/sc && cd "$_"
    if [[ ! -d "$COMPILE_PATH" ]]; then
        echo -e "\nCloning and compiling repo...\n"
        git clone "$GITHUB_PATH" gl4es && cd "$_"
    else
        echo -e "\nDirectory already exists. Updating and compiling repo...\n"
        cd "$COMPILE_PATH"
        git pull
        rm -r build
    fi
    mkdir build && cd "$_"
    cmake .. -DBCMHOST=1 -DCMAKE_BUILD_TYPE=RELEASE
    make_with_all_cores
    echo -e "\nDone!. You can found the library at $COMPILE_PATH/lib"
    exit_message
}

compile