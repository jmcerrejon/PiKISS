#!/bin/bash
#
# Description : Dune 2
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.3.1 (26/Jun/20)
# Compatible  : Raspberry Pi 1-4 (tested)
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }
clear

DATA_DIR="$HOME/.config/dunelegacy/data"
DUNE2_GAME="http://www.bestoldgames.net/download/bgames/dune-2.zip"

downloadData() {
	echo -e "\nDownloading Dune Data,...\n"
	# Dune 2 Abandonware borrowed from bestoldgames.net
	wget -O /tmp/dune2.zip $DUNE2_GAME

	mkdir -p $DATA_DIR
	unzip /tmp/dune2.zip -d $DATA_DIR *.PAK

	# Cleaning the House
	rm /tmp/dune2.*
}

installGame() {
	echo -e "\nInstalling Dune Legacy, please wait...\n"
	wget -O /tmp/dunelegacy_0.96.4_armhf.deb https://sourceforge.net/projects/dunelegacy/files/dunelegacy/0.96.4/dunelegacy_0.96.4_armhf.deb/download
	sudo dpkg -i /tmp/dunelegacy_0.96.4_armhf.deb
}

init() {
	echo -e "\nInstalling dependencies...\n"
	if ! isPackageInstalled libopusfile0; then
		sudo apt install -y libopusfile0
	fi
	if ! isPackageInstalled libsdl2-mixer-2.0-0; then
		sudo apt install -y libsdl2-mixer-2.0-0
	fi
}

askDownloadDataFiles() {
	dialog --backtitle "piKiss" \
		--title     "[ Download Dune 2 Abandonware ]" \
		--yes-label "Yes" \
		--no-label  "No" \
		--yesno     "You need the original .PAK files from the original game. Do you want to download? (In some countries the laws may consider it pirate software)" 7 55
	retval=$?

	case $retval in
		0) echo -e "Installing...\n"; downloadData; return 0 ;;
		1) clear ; echo --e "\nPlease copy into ~/.config/dunelegacy/data all the .PAK files from the original game. " ; return 0 ;;
	esac
}

init
installGame
askDownloadDataFiles

echo -e "\nType dunelegacy to play the game Or Go to Menu > Games > Dunelegacy.\n"
read -p "Press [Enter] to continue..."
