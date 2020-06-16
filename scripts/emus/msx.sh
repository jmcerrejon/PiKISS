#!/bin/bash
#
# Description : OpenMSX emulator
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.3.2 (26/Sep/19)
# Compatible  : Raspberry Pi 1-4 (tested)
#
# CREDITS     : I want to thanks to *Patrick (VampierMSX)* from **OpenMSX Team**.
#

clear
SC_OPENMSX="https://github.com/openMSX/openMSX/releases/download/RELEASE_0_15_0/openmsx-0.15.0.tar.gz"
BIN_OPENMSX="https://misapuntesde.com/res/openmsx_0.15.0-1_armhf.deb"
BINARY="openmsx_0.15.0-1_armhf.deb"
INSTALL_DIR="$HOME/games"
# ROM game Thanks to msx.ebsoft.fr
ROM_PATH="https://msx.ebsoft.fr/uridium/ccount/click.php?id=uridium"
GAMES_PATH="$HOME/games/msx"
SYSTEMROMS_URL="https://www.msxarchive.nl/pub/msx/emulator/openMSX/systemroms.zip"
SYSTEMROMS="$HOME/.openMSX/share/systemroms"
INPUT=/tmp/msxmenu.$$

downloadGame(){
	mkdir -p $GAMES_PATH & cd $GAMES_PATH
  wget -O $GAMES_PATH/uridium.zip $ROM_PATH
	unzip uridium.zip && rm uridium.zip
}

install(){
	# We have on Raspbian Buster the latest version, so it's not needed to download from my repo. Let the code commented for future release.
	# cd $HOME
	# wget $BIN_OPENMSX
	# sudo dpkg -i $BINARY
	# rm $BINARY

	postinstall
}

postinstall(){
	mkdir -p $HOME/.openMSX/share/
	cp ../../res/settings.xml ~/.openMSX/share/
	downloadGame

	echo -e "· You can play a game installed at $GAMES_PATH \n· If you want to emulate real MSX systems and not only the free C-BIOS machines, put the system ROMs in one of the following directories: ~/.openMSX/share/systemroms\n· If you want openMSX to find MSX software referred to from replays or savestates you get from your friends, copy that MSX software to ~/.openMSX/share/software"
	read -p "Press [ENTER] to continue..."
	exit
}

sudo apt install openmsx

compile(){
	echo "Installing dependencies..."
	sudo apt-get install -y libsdl1.2-dev libsdl-ttf2.0-dev libglew-dev libao-dev libogg-dev libtheora-dev libxml2-dev libvorbis-dev tcl-dev gcc-4.8 g++-4.8
	clear
	echo "Downloading and compiling OpenMSX, be patience..."
	mkdir -p $INSTALL_DIR && cd $INSTALL_DIR
	wget -O openmsx_sc.tar.gz $SC_OPENMSX
	tar xzvf openmsx_sc.tar.gz && rm openmsx_sc.tar.gz
	cd openmsx*
	./configure
	make
	sudo make install

	postinstall
}

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
