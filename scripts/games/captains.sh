#!/bin/bash
#
# Description : Capitan Sevilla El Remake (AKA Captain 'S' The Remake)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com) and Salvador (Pi Labs)
# Version     : 1.0.1 (13/Jul/20)
# Compatible  : Raspberry Pi 3-4 (tested)
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"
URL_FILE="https://www.dropbox.com/s/2005dmat9339znc/captain_s.tar.gz?dl=0"

playNow() {
	echo
	read -p "Do you want to play Captain S right now (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		cd "$INSTALL_DIR"/captain_s && ./captain
	fi
}

uninstall() {
	read -p "Do you want to uninstall Captain S (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		rm -rf "$INSTALL_DIR"/captain_s "$HOME"/.local/share/applications/capitan*
		if [[ -e "$INSTALL_DIR"/captain_s ]]; then
			echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
			exitMessage
		fi
		echo -e "\nSuccessfully uninstalled."
		exitMessage
	fi
	playNow
}

if [[ -d "$INSTALL_DIR"/captain_s ]]; then
	echo -e "Captain S already installed.\n"
	uninstall
	exit 1
fi

copyMenuShortcuts() {
	cp -f "$INSTALL_DIR"/captain_s/extra/capitan* "$HOME"/.local/share/applications/
}

install() {
	echo -e "\nInstalling...\n"
	if ! isPackageInstalled liballegro4.4; then
		sudo apt install -y liballegro4.4
	fi
	if ! isPackageInstalled libpng12-0; then
		sudo apt install -y libpng12-0
	fi
	mkdir -p "$INSTALL_DIR" && cd "$_"
	wget -qO- -O "$INSTALL_DIR"/captain_s.tar.gz "$URL_FILE"
	tar xf captain_s.tar.gz && rm captain_s.tar.gz
	mkdir -p "$HOME"/.capitan && cp "$INSTALL_DIR"/captain_s/capitan.cfg "$HOME"/.capitan
	echo -e "Generating shorcuts menu..."
	copyMenuShortcuts
	echo -e "\nDone. To play, on Desktop go to Menu > Games or via terminal, cd $INSTALL_DIR/captain_s and type: ./captain\n\nControls: Arrow: Move | CTRL: Action | ENTER: Change character when get a sausage or change superpower when you are Captain S."
	playNow
	exitMessage
}

echo "Install Capitan Sevilla (AKA Captain S)"
echo -e "=======================================\n"
echo " · More Info: https://computeremuzone.com/ficha.php?id=754&l=en"
echo " · Languages: English, Spanish."
echo " · Install path: $INSTALL_DIR/captain_s"
echo " · NOTE: There is a bug: If you set a new language, you can't change it anymore (FIX: delete the folder ~/.capitan)."
echo ""
read -p "Press [Enter] to continue..."
install