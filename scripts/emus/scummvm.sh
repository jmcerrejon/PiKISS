#!/bin/bash
#
# Description : ScummVM
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (13/Sep/16)
# Compatible  : Raspberry Pi 1, 2 & 3 (tested)
#
clear
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"
URL_FILE="http://www.scummvm.org/frs/scummvm/1.8.1/scummvm-1.8.1-raspberrypi.tar.gz"

mkDesktopEntry() {
    sudo sh -c 'echo "[Desktop Entry]\nName=ScummVM\nComment=Game-Engine for adventure games and so on\nExec=/home/pi/games/scummvm/scummvm\nIcon=/home/pi/games/scummvm/scumm01.png\nTerminal=false\nType=Application\nCategories=Application;Game;\nPath=/home/pi/games/scummvm/" > /usr/share/applications/scummvm.desktop'
}

install() {
        sudo apt-get install -y libvorbis0a libjpeg62-turbo libpng12-0 libasound2-dev libudev-dev
        compile_sdl2
        mkdir -p $INSTALL_DIR && cd $INSTALL_DIR
        wget $URL_FILE && tar -xzvf scummvm*.tar.gz && rm scummvm*.tar.gz
        cd scummvm
        wget http://hoffer.cx/data/scumm01.png
        mkDesktopEntry
        echo "Done!. To play, on Desktop Menu > games or go to $INSTALL_DIR path and type: ./scummvm"
    exit
}

echo -e "Install ScummVM ver. 1.8.1\n==========================\n\n· More Info: http://www.scummvm.org/\n\n· Get free games: http://www.scummvm.org/games/\n\n· Install path: $INSTALL_DIR/scummvm"
install
