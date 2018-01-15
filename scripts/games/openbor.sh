#!/bin/bash
#
# Description : OpenBOR
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.2 (06/Sep/16)
# Compatible  : Raspberry Pi 1, 2 & 3 (tested), Debian
# Help				: https://www.raspberrypi.org/forums/viewtopic.php?f=78&t=26859&start=25
# 					  · Games: https://mega.co.nz/#F!4xMgTDTA!bnfrA4RapYRvS31jSak3IQ
# http://cavernofcreativity.com/Atlas/xthreads_attach.php/432_1432021152_aa0362dd/9920f797b8fdb0dbdce5b886be3d582d/ARAH%202015.zip
clear

. ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

mkDesktopEntry(){
	if [[ ! -e ~/.local/share/applications/openbor.desktop ]]; then
cat << EOF > ~/.local/share/applications/openbor.desktop
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
mkDesktopEntry

SDL_fix_Rpi
sudo apt-get install -y libsdl-gfx1.2-5

if [[ ! -e /usr/lib/arm-linux-gnueabihf/libSDL_gfx.so.13 ]]; then
	sudo ln -s /usr/lib/arm-linux-gnueabihf/libSDL_gfx.so.15 /usr/lib/arm-linux-gnueabihf/libSDL_gfx.so.13
fi

mkdir -p $HOME/games && cd $_
wget http://misapuntesde.com/res/openbor_by_ulysess.tar.gz
tar xzvf openbor*
rm openbor_by_ulysess.tar.gz

echo -e "\nDone!.\n· First copy pak files inside Paks directory and run ./unpack.sh\n· To play, run: $HOME/games/openbor/openbor_rpi"
read -p "Press [ENTER] to continue..."
