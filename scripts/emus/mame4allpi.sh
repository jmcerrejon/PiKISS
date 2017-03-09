#!/bin/bash -x
#
# Description : MAME for ALL
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.8 (09/Mar/17)
# Compatible  : Raspberry Pi 1, 2 & 3 (tested)
#
# TODO: MAME with GCC 6
#
clear

. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

URL_MAME4ALL="http://sourceforge.net/projects/mame4allpi/files/latest/download?source=files"
URL_ADVMAME="https://github.com/amadvance/advancemame/releases/download/v3.4/advancemame_3.4-1_armhf.deb"
URL_MAME="http://choccyhobnob.com/?d=1535"
ROMS_URL="http://download.freeroms.com/mame_roms/c/commando.zip"

mkDesktopEntry() {
	if [[ ! -e /usr/share/applications/mame.desktop ]]; then
        sudo wget http://img.app-island.com/article/22/34/icon.png -O /usr/share/pixmaps/mame.png
		sudo sh -c 'echo "[Desktop Entry]\nName=MAME\nComment=Multiple Arcade Machine Emulator\nExec='$HOME'/games/mame4allpi/mame\nIcon=/usr/share/pixmaps/mame.png\nTerminal=false\nType=Application\nCategories=Application;Game;\nPath='$HOME'/games/mame4allpi/" > /usr/share/applications/mame.desktop'
	fi
}

advmame_install() {
	INSTALL_DIR="~/.advance/roms"
	wget -O /tmp/advancemame_3.4-1_armhf.deb $URL_MAME
	sudo dpkg -i /tmp/advancemame_3.4-1_armhf.deb
	mkdir -p $INSTALL_DIR
	wget -P $INSTALL_DIR $ROMS_URL
	rm /tmp/advancemame_3.4-1_armhf.deb
	read -p "Done!. You need to exit from Desktop and type advmame commando to play. Copy ROMs to ~/.advance/roms. Press [ENTER] to continue..."
}

mame_install() {
	ask_gcc6
	INSTALL_DIR="~/games/mame0183b_rPi"
	sudo apt install -y libsdl2-dev libsdl2-ttf-2.0-0 libqt5widgets5
	mkdir -p $HOME/games && cd $HOME/games
	wget -O temp.zip $URL_MAME && unzip temp.zip && rm temp.zip
	read -p "Done!. type $INSTALL_DIR/mame to Play. Press [ENTER] to continue..."
}

mame4all_install() {
		INSTALL_DIR="$HOME/games/mame4allpi"
    if [[ ! -e $INSTALL_DIR ]]; then
        mkdir -p $INSTALL_DIR && cd $_
        wget -qO- -O $INSTALL_DIR/tmp.zip $URL_MAME4ALL && unzip -o $INSTALL_DIR/tmp.zip && rm $INSTALL_DIR/tmp.zip
        wget -P $INSTALL_DIR/roms $ROMS_URL
        mkDesktopEntry
    fi
    echo "Done!. To play, on Desktop Menu > games or go to $INSTALL_DIR path, copy any rom to /roms directory and type: ./mame"
    read -p "Press [Enter] to continue..."
    exit
}

cmd=(dialog --separate-output --title "[ MAME For Raspberry PI ]" --checklist "Move with the arrows up & down. ESC to exit. Space to select the emulator you want to install:" 11 135 16)
options=(
   ADVANCED_MAME "based on Franxis MAME4ALL (MAME 0.37b5). This version emulates 2270 different 0.375b5 romsets." on
	 MAME_0.183 "MAME originally stood for Multiple Arcade Machine Emulator compiled by Choccy (NOT SAFE). It requires GCC-6." off
   MAME4ALL "based on Franxis MAME4ALL (MAME 0.37b5). This version emulates 2270 different 0.375b5 romsets." off)

choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

for choice in $choices
do
    case $choice in
        ADVANCED_MAME)
            advmame_install
            ;;
        MAME_0.183)
            mame_install
            ;;
        MAME4ALL)
            mame4all_install
            ;;
    esac
done
