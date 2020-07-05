#!/bin/bash
#
# Description : Super Mario 64
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (04/Jul/20)
# Compatible  : Raspberry Pi 4 (tested)
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME"/games
GAME_PATH="https://www.dropbox.com/s/69eblvaz8y0ts7w/sm64.tar.gz?dl=0"
ROM_PATH="https://s2roms.cc/s3roms/Nintendo%2064/P-T/Super%20Mario%2064%20%28U%29%20%5B%21%5D.zip"
GITHUB_PATH="https://github.com/sm64pc/sm64ex.git"
INPUT=/tmp/sm64menu.$$

if  [[ -d "$INSTALL_DIR"/sm64 ]] ; then
    echo -e "Super Mario 64 already installed.\n"
	runme
fi

generateIcon() {
    if [[ ! -e ~/.local/share/applications/smario64.desktop ]]; then
cat << EOF > ~/.local/share/applications/smario64.desktop
[Desktop Entry]
Name=Super Mario 64
Exec=/home/pi/games/sm64/sm64
Icon=/home/pi/games/sm64/icon.jpg
Type=Application
Comment=Super Mario 64 is a 1996 platform video game for the Nintendo 64 and the first in the Super Mario series to feature 3D gameplay.
Categories=Game;ActionGame;
Path=/home/pi/games/sm64
EOF
    fi
}

compile() {
    sudo apt install -y libaudiofile-dev libglew-dev libsdl2-dev
	cd "$INSTALL_DIR"
	git clone "$GITHUB_PATH" mario64 && cd "$_"
	wget -O ./sm64.zip --no-check-certificate "$ROM_PATH"
	unzip sm64.zip && rm sm64.zip
	mv Super\ Mario\ 64\ \(U\)\ \[\!\].z64 baserom.us.z64
	echo -e "\n\nCompiling... Estimated time on RPi 4: <5 min.\n"
	make TARGET_RPI=1 -j4
	cd build/us_pc
	echo -e "\n\nDone! ALT+ENTER full-screen | SPACE Select | WSAD for move | Arrows for camera, [KL,.] for actions.\n"
	read -p "Press [ENTER] to run the game."
	./sm64.us.f3dex2e.arm
}

install() {
	echo -e "\n\nInstalling, please wait..."
    if [[ $(validate_url "$GAME_PATH") != "true" ]] ; then
        read -p "Sorry, the game is not available here: $GAME_PATH. Try to compile."
        exit
	fi

	mkdir -p "$INSTALL_DIR" && cd "$_"
	wget -4 -qO- -O ./sm64.tar.gz "$GAME_PATH" && tar -xzf sm64.tar.gz && rm sm64.tar.gz
	echo -e "\n\nGenerating icon..."
	generateIcon
    echo -e "\n\nDone!. You can play typing $INSTALL_DIR/sm64/sm64 or opening the Menu > Games > Super Mario 64.\n"
    echo -e "ALT+ENTER full-screen | SPACE Select | WSAD for move | Arrows for camera, [KL,.] for actions.\n"
	runme
}

runme() {
	read -p "Press [ENTER] to run the game..."
	cd "$INSTALL_DIR"/sm64 && ./sm64
	read -p "Press ENTER to go back to main menu"
	exit
}

menu() {
	while true
	do
		dialog --clear   \
			--title     "[ Super Mario 64 ]" \
			--menu      "Select from the list:" 11 68 3 \
			INSTALL   "binary (Recommended)" \
			COMPILE   "latest from source code. Estimated time: 5 minutes." \
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
