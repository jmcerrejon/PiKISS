#!/bin/bash
#
# Description : Diablo 2 Exp. Spanish for Raspberry Pi
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.3 (03/Jul/20)
# Compatible  : Raspberry Pi 4 (tested)
#
# Info		  : Thks to PI Labs
# Help		  : xrandr --newmode "800x600_60.00"  38.25  800 832 912 1024 600 603 607 624 -hsync +vsync or xrandr --newmode HDMI-1 800x600_60.00
#

. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

D2_PATH='https://archive.org/download/diabl02sp/diablo2.tar.xz'
GAMES_PATH="$HOME/games"
SCRIPT_PATH="$HOME/games/diablo2/diablo2.sh"

generateIconDiablo2() {
    if [[ ! -e ~/.local/share/applications/diablo2.desktop ]]; then
cat << EOF > ~/.local/share/applications/diablo2.desktop
[Desktop Entry]
Name=Diablo 2 Lod of Destruction
Exec=/home/pi/games/diablo2/diablo2.sh
Icon=/home/pi/games/diablo2/diabloII.ico
Type=Application
Comment=Set in the fictional Kingdom of Khanduras in the mortal realm, Diablo makes the player take control of a lone hero battling to rid the world of Diablo
Categories=Game;ActionGame;
EOF
    fi
}

copyRunScript() {
	mkdir -p "$GAMES_PATH"/diablo2 && cp ./res/diablo2.sh "$GAMES_PATH"/diablo2/diablo2.sh
}

install() {
	if ! isPackageInstalled wine; then
		sudo apt install -y wine
	fi
	installMesa
	if [ ! -d "$HOME"/games/diablo2 ]; then
		mkdir -p "$GAMES_PATH" && cd "$_"
		wget $D2_PATH
		tar xvf diablo2.tar.xz
		rm diablo2.tar.xz
	fi
}

install
copyRunScript
generateIconDiablo2

read -p "Done!. Open Terminal, type winecfg and set resolution 800X600. Then, run $SCRIPT_PATH or click on Menu > Games > Diablo 2 Lod of Destruction. Press [ENTER] to go back to the menu..."
