#!/bin/bash
#
# Description : Diablo for Raspberry Pi
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.1 (08/Jun/20)
# Compatible  : Raspberry Pi 3-4 (tested)
#
# Help		  : https://github.com/diasurgical/devilutionX/
#

. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

BIN_PATH='https://github.com/diasurgical/devilutionX/releases/download/1.0.1/devilutionx-linux-armhf.7z'
DIABDAT_PATH='https://www.dropbox.com/s/42w96s1i9sahml7/diabdat.mpq?dl=0'

generateIconDiablo1(){
    if [[ ! -e ~/.local/share/applications/diablo1.desktop ]]; then
cat << EOF > ~/.local/share/applications/diablo1.desktop
[Desktop Entry]
Name=Diablo 1
Exec=/usr/games/diablo1/devilutionx
Icon=terminal
Type=Application
Comment=Set in the fictional Kingdom of Khanduras in the mortal realm, Diablo makes the player take control of a lone hero battling to rid the world of Diablo
Categories=Game;ActionGame;
EOF
    fi
}

install(){
	sudo mkdir -p /usr/games/diablo1 && cd $_
	sudo chown -R pi /usr/games/diablo1
	wget $BIN_PATH
	7z e devilutionx-linux-armhf.7z
	rm -rf devilutionx-linux-armhf*
	wget -O diabdat.mpq $DIABDAT_PATH
	if ! isPackageInstalled libsdl2-ttf-2.0-0; then
		sudo apt install -y libsdl2-ttf-2.0-0
	fi
	if ! isPackageInstalled libsdl2-mixer-2.0-0; then
		sudo apt install -y libsdl2-mixer-2.0-0
	fi
}

install
generateIconDiablo1

read -p "Done!. type /usr/games/diablo1/devilutionx to Play or go to Start button > Games > Diablo1 (if proceed). Press [ENTER] to continue..."

