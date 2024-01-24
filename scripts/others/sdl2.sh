#!/bin/bash
#
# Description : Compile SDL2
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 2.0.0 (24/Jan/24)
# Tested      : Raspberry Pi 5
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

install() {
    compile_sdl2
    compile_sdl2_image
    compile_sdl2_mixer
    compile_sdl2_ttf
    compile_sdl2_net
    exit_message
}

install_script_message
echo "
Compile latest SDL2 for Raspberry Pi
====================================

 · More info: https://www.libsdl.org/download-2.0.php
 · Compile sd2, sdl2_image, asl2_mixer, sdl2_ttf & sdl2_net
 · Install path: /usr/lib
 · It will take a while. Grab a coffe :)
"
read -p "Press [ENTER] to continue..."
install
