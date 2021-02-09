#!/bin/bash
#
# Description : GL4ES from ptitSeb
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.2 (03/Jan/21)
# Compatible  : Raspberry Pi 1-4
# Repository  : https://github.com/ptitSeb/gl4es
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly COMPILE_PATH="$HOME/sc/gl4es"
readonly PACKAGES_DEV=(libx11-dev)
readonly GITHUB_PATH="https://github.com/ptitSeb/gl4es.git"

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"

    mkdir -p "$HOME"/sc && cd "$_" || exit 1
    if [[ ! -d "$COMPILE_PATH" ]]; then
        echo -e "\nCloning and compiling repo...\n"
        git clone "$GITHUB_PATH" gl4es && cd "$_" || exit 1
    else
        echo -e "\nDirectory already exists. Updating and compiling repo...\n"
        cd "$COMPILE_PATH" || exit 1
        git pull
        rm -r build
    fi
    mkdir build && cd "$_" || exit 1
    if [ "$(dpkg -l | awk '/mesa0/ {print }'|wc -l)" -ge 1 ]; then
        cmake .. -DBCMHOST=1 -DCMAKE_BUILD_TYPE=RELEASE
    else
        cmake .. -DODROID=1 -DCMAKE_BUILD_TYPE=RELEASE
    fi
    make_with_all_cores
    echo -e "\nDone!. You can found the library at $COMPILE_PATH/lib"
    exit_message
}

compile
