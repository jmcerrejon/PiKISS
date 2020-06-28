#!/bin/bash
#
# Description : Multi emulator Mednafen
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (19/Jun/20)
# Compatible  : Raspberry Pi 1-2 (¿?), 3-4 (tested)
#
# Compile deps: libsndfile1-dev libsdl2-dev. Time compiling with RPi 4 not overclocked: 
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }
clear

URL_FILE="https://www.dropbox.com/s/nrkvem2vxjhxt74/mednafen_1-24.3_armhf.deb?dl=0"

install() {
    if isPackageInstalled mednafen; then
		read -p "Mednafen is already installed!. Press [Enter] to go back to the menu..."
		return 0
    fi

	echo -e "\nInstalling, please wait...\n"

	if ! isPackageInstalled libsndfile1; then
		sudo apt install -y libsndfile1
	fi

	if ! isPackageInstalled libsdl2; then
		sudo apt install -y libsdl2
	fi

	wget -4 -qO- -O /tmp/mednafen.deb "$URL_FILE" && sudo dpkg --force-all -i /tmp/mednafen.deb && rm /tmp/mednafen.deb
	# Fix issue with the installation due dependencies
	sudo apt --fix-broken install

    echo -e "\nDone!. To play, type: mednafen <rom_file>\n"
    read -p "Press [Enter] to go back to the menu..."
}

echo -e "Mednafen is a portable argument(command-line)-driven multi-system emulator that emulates:\n\n \
· Apple II/II+, Atari Lynx, Neo Geo Pocket (Color), WonderSwan\n \
· GameBoy (Color), GameBoy Advance, Nintendo Entertainment System, Super Nintendo Entertainment System/Super Famicom\n \
· Virtual Boy, PC Engine/TurboGrafx 16 (CD), SuperGrafx, PC-FX\n \
· Sega Game Gear, Sega Genesis/Megadrive, Sega Master System\n \
· Sony PlayStation\n"

install
