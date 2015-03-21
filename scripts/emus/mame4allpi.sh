#!/bin/bash
#
# Description : MAME4ALL for Pi by Squid
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.3 (21/Mar/15)
# Compatible  : Raspberry Pi 1 & 2 (tested)
#
clear

. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games/mame4allpi"
URL_FILE="http://sourceforge.net/projects/mame4allpi/files/latest/download?source=files"

install(){
    if [[ ! -e $HOME/games/mame4allpi ]]; then
        mkdir -p $INSTALL_DIR && cd $_
        wget -qO- -O $INSTALL_DIR/tmp.zip $URL_FILE && unzip -o $INSTALL_DIR/tmp.zip && rm $INSTALL_DIR/tmp.zip    
    fi
    echo "Done!. To play go to install path, copy any rom to /roms directory and type: ./mame"
    read -p "Press [Enter] to continue..."
    exit
}

echo -e "MAME4ALL for Pi (latest)\n========================\n\n· More Info: http://sourceforge.net/projects/mame4allpi\n· Install path: $INSTALL_DIR\n\nInstalling, please wait..."
install