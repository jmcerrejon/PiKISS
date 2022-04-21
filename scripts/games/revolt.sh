#!/bin/bash
#
# Description : Re-Volt is a radio control car racing themed video game.
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.3 (07/Feb/21)
# Compatible  : Raspberry Pi 3-4 (tested on Raspberry Pi 4)
#
# HELP	      : Thanks to PI LAB (https://www.youtube.com/channel/UCgfQjdc5RceRlTGfuthBs7g) and Meverick
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

DATA_PATH="https://misapuntesde.com/rpi_share/rvgl-data.deb"
APP_PATH="https://misapuntesde.com/rpi_share/rvgl.deb"

installer() {
    sudo dpkg --add-architecture armhf
    sudo apt update
    sudo apt install -y libsdl2-image-2.0-0:armhf libunistring-dev:armhf libenet7:armhf libvorbisfile3:armhf libmpg123-0:armhf libdumb1:armhf libmodplug1:armhf libfluidsynth2:armhf
    fix_libGLES
    cd ~
    if [ ! -f /usr/local/bin/rvgl_start ]; then
        wget -O rvgl-data.deb $DATA_PATH
        wget -O rvgl.deb $APP_PATH
        sudo dpkg -i rvgl-data.deb rvgl.deb
        rm rvgl-data.deb rvgl.deb
    fi
}

echo -e "Installing Re-Volt...\n=====================\n\n· Please wait...\n"

installer

read -p "Done!. type rvgl_start to Play or go to Desktop Game Menu option. Follow the instructions to download game's data files. Press [ENTER] to continue..."
