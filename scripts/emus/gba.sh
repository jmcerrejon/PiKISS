#!/bin/bash
#
# Description : Gameboy Advance emulator mgba
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.3.1 (19/Jun/20)
# Compatible  : Raspberry Pi 1 & 2 (¿?), 4 (tested)
#
# Help        : https://github.com/mgba-emu/mgba/
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }
clear

INSTALL_DIR="$HOME/games"
URL_FILE="https://www.dropbox.com/s/r7fuex5dtfpi1u4/mgba_0-90.tar.gz?dl=0"

install() {
    if [[ -f "$INSTALL_DIR"/mgba/mgba ]]; then
		read -p "mGBA is already installed!. Press [Enter] to go back to the menu..."
		return 0
    fi

	echo -e "\nInstalling, please wait...\n"

	if ! isPackageInstalled libglu1-mesa; then
		sudo apt install -y libglu1-mesa
	fi

	if ! isPackageInstalled libzip4; then
		sudo apt install -y libzip4
	fi

	mkdir -p "$INSTALL_DIR" && cd "$_"
	wget -4 -qO- -O mgba-0.90.tar.gz "$URL_FILE" && tar -xzf mgba-0.90.tar.gz && rm mgba-0.90.tar.gz

    echo -e "\nDone!. To play, go to $INSTALL_DIR/mgba path and type: ./mgba_full.sh roms/<rom_name>.gba\n"
    read -p "Press [Enter] to go back to the menu..."
}

echo -e "Gameboy Advance Emulator (mgba)\n===============================\n\n· More Info: https://github.com/mgba-emu/mgba/\n· Homebrew ROMs included.\n· Install path: $INSTALL_DIR/gpsp\n"
install
