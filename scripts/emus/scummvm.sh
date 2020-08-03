#!/bin/bash
#
# Description : ScummVM
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.2 (03/Aug/20)
# Compatible  : Raspberry Pi 1-4 (tested)
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"
PACKAGES=( libSDL2-net-2.0-0 )
URL_FILE="https://www.dropbox.com/s/edlpjjwintcqb7p/scummvm_2-1.2_armhf.deb?dl=0"

install() {
	installPackagesIfMissing "${PACKAGES[@]}"
	
	wget -4 -qO- -O /tmp/scummvm.deb "$URL_FILE" && sudo dpkg --force-all -i /tmp/scummvm.deb && rm /tmp/scummvm.deb
	
	echo -e "\nDone!. To play, on Desktop Menu > games or type: ./scummvm\n"
	read -p "Press [Enter] to go back to the menu..."
}

echo -e "ScummVM\n=======\n\n· More Info: https://www.scummvm.org/\n\n· Get free games: https://www.scummvm.org/games/\n\n· Install path: $INSTALL_DIR/scummvm\n"
install
