#!/bin/bash
#
# Description : Duke Nukem 3D
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (07/Jul/20)
# Compatible  : Raspberry Pi 4 (tested)
#
# Help		  : https://www.techradar.com/how-to/how-to-run-wolfenstein-3d-doom-and-duke-nukem-on-your-raspberry-pi
# 			  : https://github.com/RetroPie/RetroPie-Setup/wiki/Duke-Nukem-3D
# 			  : http://wiki.eduke32.com/wiki/Building_EDuke32_on_Linux#Prerequisites_for_the_build
# 			  : https://github.com/nukeykt/NBlood/issues/332
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME"/games
GAME_PATH="https://www.dropbox.com/s/zo3jnm48j58vakd/eduke32.tar.gz?dl=0"
GITHUB_PATH="https://voidpoint.io/terminx/eduke32.git"
SHAREWARE_DATA_PATH="http://hendricks266.duke4.net/files/3dduke13_data.7z"
INPUT=/tmp/eduke32.$$

if  [[ -d "$INSTALL_DIR"/eduke32 ]] ; then
    echo -e "Duke Nukem 3D already installed!\n"
	runme
fi

generateIcon() {
    if [[ ! -e ~/.local/share/applications/eduke32.desktop ]]; then
cat << EOF > ~/.local/share/applications/eduke32.desktop
[Desktop Entry]
Name=Duke Nukem 3D
Exec=/home/pi/games/eduke32/eduke32
Icon=/home/pi/games/eduke32/icon.png
Type=Application
Comment=Duke Nukem 3D is a First Person Shooter game developed by 3D Realms in 1996.
Categories=Game;ActionGame;
Path=/home/pi/games/eduke32
EOF
    fi
}

copySharewareFiles() {
	cd "$INSTALL_DIR"/eduke32
	if ! isPackageInstalled p7zip; then
		sudo apt install -y p7zip
	fi
	wget "$SHAREWARE_DATA_PATH"
	p7zip -d 3dduke13_data.7z
}

compile() {
    sudo apt-get install -y build-essential nasm libgl1-mesa-dev libglu1-mesa-dev libsdl1.2-dev libsdl-mixer1.2-dev libsdl2-dev libsdl2-mixer-dev flac libflac-dev libvorbis-dev libvpx-dev libgtk2.0-dev freepats
	cd "$INSTALL_DIR"
	git clone "$GITHUB_PATH" eduke32 && cd "$_"
	sed -i -e 's/  glrendmode = (settings.polymer) ? REND_POLYMER : REND_POLYMOST;/  int glrendmode = (settings.polymer) ? REND_POLYMER : REND_POLYMOST;/g' source/duke3d/src/startgtk.game.cpp
	echo -e "\n\nCompiling... Estimated time on RPi 4: <5 min.\n"
	make -j4 WITHOUT_GTK=1 POLYMER=1 USE_LIBVPX=0 HAVE_FLAC=0 OPTLEVEL=3 LTO=0 RENDERTYPESDL=1 HAVE_JWZGLES=1 USE_OPENGL=1 OPTOPT="-march=armv8-a+crc -mtune=cortex-a53"
	copySharewareFiles
	echo -e "\n\nDone!.\n"
	read -p "Press [ENTER] to run the game."
}

install() {
	echo -e "\n\nInstalling, please wait..."
    if [[ $(validate_url "$GAME_PATH") != "true" ]] ; then
        read -p "Sorry, the game is not available here: $GAME_PATH. Try to compile."
        exit
	fi

	mkdir -p "$INSTALL_DIR" && cd "$_"
	copySharewareFiles
	wget -4 -qO- -O ./eduke32.tar.gz "$GAME_PATH" && tar -xzf eduke32.tar.gz && rm eduke32.tar.gz
	echo -e "\n\nGenerating icon..."
	generateIcon
    echo -e "\n\nDone!. You can play typing $INSTALL_DIR/eduke32/eduke32 or opening the Menu > Games > Duke Nukem 3D.\n"
	runme
}

runme() {
	read -p "Press [ENTER] to run the game..."
	cd "$INSTALL_DIR"/eduke32 && ./eduke32
	read -p "Press ENTER to go back to main menu"
	exit
}

menu() {
	while true
	do
		dialog --clear   \
			--title     "[ Duke Nukem 3D Shareware ]" \
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
