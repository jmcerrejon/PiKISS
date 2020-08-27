#!/bin/bash
#
# Description : Open Supaplex
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (27/Aug/20)
# Compatible  : Raspberry Pi 4 (tested)
# Repository  : https://github.com/sergiou87/open-supaplex
#

. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"
BINARY_PATH="https://misapuntesde.com/rpi_share/open-supaplex-rpi.tar.gz"
PACKAGES=(libsdl2-mixer-2.0-0)

runme() {
	echo
	if [ ! -f "$INSTALL_DIR"/open-supaplex/opensupaplex.sh ]; then
		echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
		exit_message
	fi
	read -p "Press [ENTER] to run the game..."
	cd "$INSTALL_DIR"/open-supaplex && ./opensupaplex.sh
	clear
	exit_message
}

remove_files() {
	rm -rf "$INSTALL_DIR"/open-supaplex ~/.local/share/applications/opensupaplex.desktop
}

uninstall() {
	read -p "Do you want to uninstall Open Supaplex (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		remove_files
		if [[ -e "$INSTALL_DIR"/open-supaplex ]]; then
			echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
			exit_message
		fi
		echo -e "\nSuccessfully uninstalled."
		exit_message
	fi
	exit_message
}

if [[ -d "$INSTALL_DIR"/open-supaplex ]]; then
	echo -e "Open Supaplex already installed.\n"
	uninstall
	exit 1
fi

generate_icon() {
	echo -e "\nGenerating icon..."
	if [[ ! -e ~/.local/share/applications/opensupaplex.desktop ]]; then
		cat <<EOF >~/.local/share/applications/opensupaplex.desktop
[Desktop Entry]
Name=Open Supaplex
Exec=/home/pi/games/open-supaplex/opensupaplex.sh
Icon=/home/pi/games/open-supaplex/icon.png
Path=/home/pi/games/open-supaplex/
Type=Application
Comment=Supaplex is a game made in the early nineties.
Categories=Game;
EOF
	fi
}

install() {
	echo -e "\nInstalling Open Supaplex, please wait..."
    installPackagesIfMissing "${PACKAGES[@]}"
	download_and_extract "$BINARY_PATH" "$INSTALL_DIR"
	echo -e "\nType in a terminal $INSTALL_DIR/opensupaplex/opensupaplex.sh or go to Menu > Games > Open Supaplex."
}

install
generate_icon
runme