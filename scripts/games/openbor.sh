#!/bin/bash
#
# Description : OpenBOR
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (23/May/15)
# Compatible  : Raspberry Pi 1 & 2 (tested), Debian
# Help				: https://www.raspberrypi.org/forums/viewtopic.php?f=78&t=26859&start=25
# 					  · Games: https://mega.co.nz/#F!4xMgTDTA!bnfrA4RapYRvS31jSak3IQ
#
clear

mkDesktopEntry(){
	if [[ ! -e /usr/share/applications/openbor.desktop ]]; then
		sudo sh -c 'echo "[Desktop Entry]\nName=OpenBOR\nComment=OpenBOR is the open source continuation of Beats of Rage, a Streets of Rage tribute game.\nExec='$PWD'/openbor_rpi\nIcon=terminal\nTerminal=true\nType=Application\nCategories=Game;\nPath='$PWD'/" > /usr/share/applications/openbor.desktop'
	fi
}

mkDesktopEntry

mkdir -p $HOME/games
wget http://misapuntesde.com/res/openbor_by_ulysess.tar.gz
tar xvf openbor*

echo -e "\nDone!. First copy pak files inside Paks directory and run ./unpack.sh\n To play, run: /games/openbor/openbor_rpi"
read -p "Press [ENTER] to continue..."