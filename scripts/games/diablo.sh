#!/bin/bash
#
# Description : Diablo for Raspberry Pi
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.3 (15/Jul/20)
# Compatible  : Raspberry Pi 3-4 (tested)
#
# Help		  : https://github.com/diasurgical/devilutionX/
#

. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"
BIN_PATH='https://github.com/diasurgical/devilutionX/releases/download/1.0.1/devilutionx-linux-armhf.7z'
DIABDAT_PATH='https://www.dropbox.com/s/42w96s1i9sahml7/diabdat.mpq?dl=0'
ICON="https://misapuntesde.com/res/diablo1.png"

playNow() {
	echo
	read -p "Do you want to play Diablo1 now? [y/n] " option
	case "$option" in
		y*) "$INSTALL_DIR"/diablo1/devilutionx ;;
	esac
	clear
	exitMessage
}

uninstall() {
	read -p "Do you want to uninstall Diablo 1 (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		rm -rf "$INSTALL_DIR"/diablo1 ~/.local/share/applications/diablo1.desktop ~/.local/share/diasurgical
		if [[ -e "$INSTALL_DIR"/diablo1 ]]; then
			echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
			exitMessage
		fi
		echo -e "\nSuccessfully uninstalled."
		exitMessage
	fi
	playNow
}

if [[ -d "$INSTALL_DIR"/diablo1 ]]; then
	echo -e "Diablo 1 already installed.\n"
	uninstall
	exit 1
fi

generateIconDiablo1() {
	echo -e "\n\nGenerating icon..."
	wget -qO- -O "$INSTALL_DIR"/diablo1/diablo1.png "$ICON"
	if [[ ! -e ~/.local/share/applications/diablo1.desktop ]]; then
		cat <<EOF >~/.local/share/applications/diablo1.desktop
[Desktop Entry]
Name=Diablo 1
Exec=/home/pi/games/diablo1/devilutionx
Icon=/home/pi/games/diablo1/diablo1.png
Type=Application
Comment=Set in the fictional Kingdom of Khanduras in the mortal realm, Diablo makes the player take control of a lone hero battling to rid the world of Diablo
Categories=Game;ActionGame;
EOF
	fi
}

installDependencies() {
	if ! isPackageInstalled p7zip; then
		sudo apt install -y p7zip
	fi
	if ! isPackageInstalled libsdl2-ttf-2.0-0; then
		sudo apt install -y libsdl2-ttf-2.0-0
	fi
	if ! isPackageInstalled libsdl2-mixer-2.0-0; then
		sudo apt install -y libsdl2-mixer-2.0-0
	fi
}

install() {
	echo -e "\nInstalling Diablo 1, please wait...\n"
	installDependencies

	mkdir -p "$INSTALL_DIR" && cd "$_"
	wget -qO devilutionx-linux-armhf.7z "$BIN_PATH"
	p7zip -d devilutionx-linux-armhf.7z
	mv devilutionx-linux-armhf diablo1 && cd "$_"
	generateIconDiablo1
	echo
	read -p "Do you have an original copy of Diablo 1 (Y/n)? " response
	if [[ $response =~ [Nn] ]]; then
		echo -e "\nPlease, copy diabdat.mpq inside $INSTALL_DIR/diablo1"
		return 1
	fi

	echo -e "\nDownloading diabdat.mpq, please wait..."
	wget -qO diabdat.mpq "$DIABDAT_PATH"
	echo -e "\nDone!. type /usr/games/diablo1/devilutionx to Play or go to Start button > Games > Diablo1 (if proceed).\n"
}

install
playNow
