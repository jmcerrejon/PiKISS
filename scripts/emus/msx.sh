#!/bin/bash
#
# Description : OpenMSX emulator
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.3.3 (19/Jun/20)
# Compatible  : Raspberry Pi 1-2 (¿?), 3-4 (tested)
#
# CREDITS     : I want to thanks to *Patrick (VampierMSX)* from **OpenMSX Team**.
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }
clear

SC_OPENMSX="https://github.com/openMSX/openMSX/releases/download/RELEASE_0_15_0/openmsx-0.15.0.tar.gz"
BIN_OPENMSX="https://misapuntesde.com/res/openmsx_0.15.0-1_armhf.deb"
BINARY="openmsx_0.15.0-1_armhf.deb"
INSTALL_DIR="$HOME/games"
SETTINGS_URL="https://raw.githubusercontent.com/jmcerrejon/PiKISS/master/res/settings.xml"
# ROM game Thanks to msx.ebsoft.fr
ROM_PATH="http://msx.ebsoft.fr/uridium/ccount/click.php?id=uridium"
SYSTEMROMS_URL="http://www.msxarchive.nl/pub/msx/emulator/openMSX/systemroms.zip"
SYSTEMROMS="$HOME/.openMSX/share/systemroms"
INPUT=/tmp/msxmenu.$$

downloadGame() {
	echo -e "\nInstalling Uridium at $INSTALL_DIR/msx/uridium48...\n"
	mkdir -p "$INSTALL_DIR"/msx && cd "$_"
	wget -qO "$INSTALL_DIR"/msx/uridium.zip "$ROM_PATH"
	unzip -q -o "$INSTALL_DIR"/msx/uridium.zip && rm "$INSTALL_DIR"/msx/uridium.zip && rm -rf "$INSTALL_DIR"/msx/__MACOSX

	playgame
}

playgame() {
    if [[ -f "$INSTALL_DIR"/msx/uridium48/URDIUM48.rom ]]; then
        read -p "Do you want to play uridium now? [y/n] " option
        case "$option" in
            y*) cd "$INSTALL_DIR"/msx/uridium48 && openmsx URDIUM48.rom ;;
        esac
    fi
}

install() {
	# We have on Raspbian Buster the latest version, so it's not needed to download from my repo. Let the code commented for future release.
	# cd $HOME && wget $BIN_OPENMSX &&  sudo dpkg -i $BINARY &&  rm $BINARY
	# if isPackageInstalled openmsx; then
	# 	read -p "OpenMSX is already installed!. Press [Enter] to go back to the menu..."
	# 	return 0
    # fi

	echo -e "\nInstalling, please wait...\n"

	sudo apt install -y openmsx

	postinstall
}

postinstall() {
	echo -e "\nInstalling ROM BiOS for maximum compatibility...\n"
	mkdir -p "$HOME"/.openMSX/share/ && cd "$_"
	wget -q "$SETTINGS_URL" "$HOME"/.openMSX/share/settings.xml
	wget -q "$SYSTEMROMS_URL" && unzip -q -o systemroms.zip && rm systemroms.zip

	downloadGame

	echo -e "\n· You can play a game installed at $INSTALL_DIR/msx\n· You have at your disposal all System ROMs BIOS at: ~/.openMSX/share/systemroms\n· If you want openMSX to find MSX software referred to from replays or savestates,\nyou get from your friends, copy that MSX software to ~/.openMSX/share/software\n"
	read -p "Press [ENTER] to come back to the menu..."
	exit
}

compile() {
	echo "Installing dependencies..."
	sudo apt-get install -y libsdl1.2-dev libsdl-ttf2.0-dev libglew-dev libao-dev libogg-dev libtheora-dev libxml2-dev libvorbis-dev tcl-dev gcc-4.8 g++-4.8
	clear
	echo "Downloading and compiling OpenMSX, be patience..."
	mkdir -p "$INSTALL_DIR" && cd "$INSTALL_DIR"
	wget -qO openmsx_sc.tar.gz $SC_OPENMSX
	tar xzvf openmsx_sc.tar.gz && rm openmsx_sc.tar.gz
	cd openmsx*
	./configure
	make
	sudo make install

	postinstall
}

menu() {
	while true
	do
		dialog --clear   \
			--title     "[ openMSX emulator ]" \
			--menu      "Select from the list:" 11 68 3 \
			INSTALL   "0.15.0 binary (Recommended)" \
			COMPILE   "latest from source code. Estimated time: 50 minutes." \
			Exit    "Exit" 2>"${INPUT}"

		menuitem=$(<"${INPUT}")

		case $menuitem in
			INSTALL) clear ; install ;;
			COMPILE) clear ; compile ;;
			Exit) exit ;;
		esac
	done
}

menu
