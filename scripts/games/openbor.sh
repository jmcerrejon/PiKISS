#!/bin/bash
#
# Description : OpenBOR
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (23/May/15)
# Compatible  : Raspberry Pi 1 & 2 (tested), Debian
# Help				: https://www.raspberrypi.org/forums/viewtopic.php?f=78&t=26859&start=25
# 					  · Games: https://mega.co.nz/#F!4xMgTDTA!bnfrA4RapYRvS31jSak3IQ
# http://cavernofcreativity.com/Atlas/xthreads_attach.php/432_1432021152_aa0362dd/9920f797b8fdb0dbdce5b886be3d582d/ARAH%202015.zip
clear

. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

mkDesktopEntry(){
	if [[ ! -e /usr/share/applications/openbor.desktop ]]; then
		sudo sh -c 'echo "[Desktop Entry]\nName=OpenBOR\nComment=OpenBOR is the open source continuation of Beats of Rage, a Streets of Rage tribute game.\nExec='$PWD'/openbor_rpi\nIcon=terminal\nTerminal=true\nType=Application\nCategories=Game;\nPath='$PWD'/" > /usr/share/applications/openbor.desktop'
	fi
}

mkDesktopEntry

SDL_fix_Rpi
sudo apt-get install -y libsdl-gfx1.2-4

mkdir -p $HOME/games
wget http://misapuntesde.com/res/openbor_by_ulysess.tar.gz
tar xzvf openbor*

echo -e "\nDone!.\n· First copy pak files inside Paks directory and run ./unpack.sh\n· To play, run: /games/openbor/openbor_rpi"
read -p "Press [ENTER] to continue..."