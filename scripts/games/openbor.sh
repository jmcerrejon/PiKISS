#!/bin/bash
#
# Description : OpenBOR
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.2.1 (23/Jul/20)
# Compatible  : Raspberry Pi 1-4 (tested)
# Help		  : https://www.raspberrypi.org/forums/viewtopic.php?f=78&t=26859&start=25
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

mkDesktopEntry() {
	if [[ ! -e ~/.local/share/applications/openbor.desktop ]]; then
		cat <<EOF >~/.local/share/applications/openbor.desktop
[Desktop Entry]
Name=OpenBOR
Exec=/home/pi/games/openbor/openbor_rpi
Icon=terminal
Type=Application
Comment=OpenBOR is the open source continuation of Beats of Rage, a Streets of Rage tribute game.
Categories=Game;ActionGame;
EOF
	fi
}

sudo apt install -y libsdl-gfx1.2-5 libpng12-0
mkDesktopEntry

if [[ ! -e /usr/lib/arm-linux-gnueabihf/libSDL_gfx.so.13 ]]; then
	sudo ln -s /usr/lib/arm-linux-gnueabihf/libSDL_gfx.so.15 /usr/lib/arm-linux-gnueabihf/libSDL_gfx.so.13
fi

mkdir -p "$HOME"/games && cd "$_"
wget -q https://misapuntesde.com/res/openbor_by_ulysess.tar.gz
tar xzvf openbor*
rm openbor_by_ulysess.tar.gz

echo -e "\nDone!.\n· First copy pak files inside Paks directory and run ./unpack.sh\n· To play, run: $HOME/games/openbor/openbor_rpi"
exit_message
