#!/bin/bash
#
# Description : MAME4ALL for Pi by Squid
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.5 (18/Apr/16)
# Compatible  : Raspberry Pi 1 & 2 (tested)
#
clear

. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games/mame4allpi"
URL_FILE="http://sourceforge.net/projects/mame4allpi/files/latest/download?source=files"
ROMS_URL="http://download.freeroms.com/mame_roms/c/commando.zip"

mkDesktopEntry() {
	if [[ ! -e /usr/share/applications/mame.desktop ]]; then
        sudo wget http://img.app-island.com/article/22/34/icon.png -O /usr/share/pixmaps/mame.png
		sudo sh -c 'echo "[Desktop Entry]\nName=MAME\nComment=Multiple Arcade Machine Emulator\nExec='$HOME'/games/mame4allpi/mame\nIcon=/usr/share/pixmaps/mame.png\nTerminal=false\nType=Application\nCategories=Application;Game;\nPath='$HOME'/games/mame4allpi/" > /usr/share/applications/mame.desktop'
	fi
}

playgame()
{
    read -p "Do you want to run mame4 now? [y/n] " option
    case "$option" in
        y*) $INSTALL_DIR/mame ;;
    esac
}

install()
{
    if [[ ! -e $INSTALL_DIR ]]; then
        mkdir -p $INSTALL_DIR && cd $_
        wget -qO- -O $INSTALL_DIR/tmp.zip $URL_FILE && unzip -o $INSTALL_DIR/tmp.zip && rm $INSTALL_DIR/tmp.zip
        wget -P $INSTALL_DIR/roms $ROMS_URL
        mkDesktopEntry
        playgame
    fi
    echo "Done!. To play go to install path, copy any rom to /roms directory and type: ./mame"
    read -p "Press [Enter] to continue..."
    exit
}

echo -e "MAME4ALL for Pi (latest)\n========================\n\n· More Info: http://sourceforge.net/projects/mame4allpi\n· Add Commando ROM\n· Install path: $INSTALL_DIR\n\nInstalling, please wait..."
install
