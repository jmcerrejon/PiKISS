#!/bin/bash
#
# Description : PPSSPP for Raspberry Pi by Pi Labs
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (15/Jul/20)
# Compatible  : Raspberry Pi 3-4
#
# Info		  : Silveredge thanks to andrewafy@gmail.com | http://wololo.net/downloads/index.php/download/937
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"
URL_FILE="https://www.dropbox.com/s/5mqck407rrspmom/ppsspp_1.9.3-1063.tar.gz?dl=0"
GAME_URL="http://cdn-0.wololo.net/download.php?f=Silveredge.zip"

uninstall() {
	read -p "Do you want to uninstall PPSSPP (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		rm -rf "$INSTALL_DIR"/ppsspp ~/.local/share/applications/ppsspp.desktop ~/.config/ppsspp
		if [[ -e "$INSTALL_DIR"/ppsspp ]]; then
			echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
			exit_message
		fi
		echo -e "\nSuccessfully uninstalled."
		exit_message
	fi
	playNow
}

if [[ -d "$INSTALL_DIR"/ppsspp ]]; then
	echo -e "PPSSPP already installed.\n"
	uninstall
	exit 1
fi

generateIcon() {
	echo -e "\n\nGenerating icon..."
	if [[ ! -e ~/.local/share/applications/ppsspp.desktop ]]; then
		cat <<EOF >~/.local/share/applications/ppsspp.desktop
[Desktop Entry]
Name=PPSSPP
Exec=/home/pi/games/ppsspp/ppssppsdl
Icon=/home/pi/games/ppsspp/assets/icon_regular_72.png
Type=Application
Comment=PPSSPP can run your PSP games on your RPi in full HD resolution
Categories=Game;ActionGame;
EOF
	fi
}

playNow() {
	echo
	read -p "Do you want to play Silveredge now? [y/n] " option
	case "$option" in
		y*) "$INSTALL_DIR"/ppsspp/ppssppsdl "$INSTALL_DIR"/ppsspp/roms/Silveredge/EBOOT.PBP ;;
	esac
	clear
	exit_message
}

downloadROM() {
	echo -e "Installing game Silveredge on $INSTALL_DIR/ppsspp/roms\n\n"
	mkdir -p "$INSTALL_DIR"/ppsspp/roms/ && cd "$_"
	wget -q -O "$INSTALL_DIR"/ppsspp/roms/silveredge.zip "$GAME_URL"
	unzip "$INSTALL_DIR"/ppsspp/roms/silveredge.zip && rm "$INSTALL_DIR"/ppsspp/roms/silveredge.zip
}

install() {
	echo -e "Installing, please wait...\n"
	mkdir -p "$INSTALL_DIR" && cd "$_"
	wget -qO- -O "$INSTALL_DIR"/tmp.tar.gz "$URL_FILE" && tar -xzf "$INSTALL_DIR"/tmp.tar.gz && rm "$INSTALL_DIR"/tmp.tar.gz "$INSTALL_DIR"/._ppsspp
	downloadROM
	generateIcon
	echo -e "\nDone!. To play go to Menu > Games > PPSSPP or open a Terminal and type: $INSTALL_DIR/ppsspp/ppssppsdl"
}

echo -e "Install PPSSPP (Version 1.9.3-1063)\n===================================\n\n· More Info: https://www.ppsspp.org/\n\n· Install free Homebrew game Silveredge (Thanks to Andrew Afy).\n\n· Install path: $INSTALL_DIR/ppsspp\n"

install
playNow
