#!/bin/bash
#
# Description : Arx Libertatis (AKA Arx Fatalis)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.2 (17/Aug/20)
# Compatible  : Raspberry Pi 4 (fail)
#
# Help		  : https://wiki.arx-libertatis.org/Downloading_and_Compiling_under_Linux
# For fans	  : https://www.reddit.com/r/ArxFatalis/
# Issue		  : ../sysdeps/unix/sysv/linux/read.c: No such file or directory
#

. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"
PACKAGES=( libglew-dev )
PACKAGES_DEV=( zlib1g-dev libfreetype6-dev libopenal1 libopenal-dev mesa-common-dev libgl1-mesa-dev libboost-dev libepoxy-dev libglm-dev libcppunit-dev libglew-dev libsdl2-dev )
CONFIG_DIR="$HOME/.local/share/arx"
BINARY_URL="https://www.littlecarnage.com/arx_rpi2.tar.gz"
SOURCE_CODE_URL="https://github.com/ptitSeb/ArxLibertatis.git"
SOURCE_CODE_OFFICIAL_URL="https://github.com/arx/ArxLibertatis.git" # Doesn't work for now
DATA_URL="https://archive.org/download/rpi_share/arx_demo_en.tgz"
ICON_URL="https://github.com/arx/ArxLibertatisData/blob/master/icons/arx-libertatis-32.png?raw=true"
INPUT=/tmp/arx.$$

runme() {
	if [ ! -f "$INSTALL_DIR"/arx/arx ]; then
		echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
		exit_message
	fi
	echo
	read -p "Press [ENTER] to run the game..."
	cd "$INSTALL_DIR"/arx && ./arx
	exit_message
}

remove_files() {
	# TODO Remove files installed with sudo make install (maybe if I make a .deb dpkg, easier)
	rm -rf ~/.local/share/applications/arx.desktop ~/.local/share/arx "$CONFIG_DIR"/arx-libertatis-32.png \
		"$INSTALL_DIR"/arx /usr/local/share/blender/scripts/addons/arx /usr/local/share/games/arx
}

uninstall() {
	read -p "Do you want to uninstall Arx Libertatis (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		remove_files
		if [[ -e "$INSTALL_DIR"/arx ]]; then
			echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
			exit_message
		fi
		echo -e "\nSuccessfully uninstalled."
		exit_message
	fi
	exit_message
}

if [[ -d "$INSTALL_DIR"/arx ]]; then
	echo -e "Arx Libertatis already installed.\n"
	uninstall
	exit 1
fi

generate_icon() {
	echo -e "\nGenerating icon..."
	mkdir -p "$CONFIG_DIR"
	wget -q "$ICON_URL" -O "$CONFIG_DIR"/arx-libertatis-32.png
	if [[ ! -e ~/.local/share/applications/arx.desktop ]]; then
		cat <<EOF >~/.local/share/applications/arx.desktop
[Desktop Entry]
Name=Arx Fatalis (AKA Arx Libertatis)
Exec=/home/pi/games/arx/arx
Icon=${CONFIG_DIR}/arx-libertatis-32.png
Type=Application
Comment=Arx Fatalis is set on a world whose sun has failed, forcing the above-ground creatures to take refuge in caverns.
Categories=Game;ActionGame;
EOF
	fi
}

fix_libndi() {
	echo -e "\nFixing library libndi.so\n"
	sudo rm -f /usr/lib/libndi.so
	sudo ln -r -s /usr/lib/libndi.so.4.0.0 /usr/lib/libndi.so
	sudo rm -f /usr/lib/libndi.so.4
	sudo ln -r -s /usr/lib/libndi.so.4.0.0 /usr/lib/libndi.so.4
}

fix_libGLEW1.7() {
	if [[ -f /usr/lib/arm-linux-gnueabihf/libGLEW.so.1.7 ]]; then
		return 0
	fi

	echo -e "\nLinking libGLEW.so -> libGLEW.so.1.7\n"
	sudo ln -s /usr/lib/arm-linux-gnueabihf/libGLEW.so /usr/lib/arm-linux-gnueabihf/libGLEW.so.1.7
}

compile() {
	installPackagesIfMissing "${PACKAGES_DEV[@]}"
	fix_libndi
	mkdir -p ~/sc && cd "$_"
	git clone "$SOURCE_CODE_URL" arx && cd "$_"
	mkdir build && cd "$_"
	CFLAGS="-fsigned-char -marm -march=armv8-a+crc -mtune=cortex-a72 -mfpu=neon-fp-armv8 -mfloat-abi=hard" CXXFLAGS="-fsigned-char" cmake .. -DBUILD_TOOLS=off -DBUILD_IO_LIBRARY=off -DBUILD_CRASHREPORTER=off -DICON_TYPE=none

	if [[ -f ~/sc/arx/build/CMakeFiles/CMakeError.log ]]; then
		echo -e "\n\nERROR!!. I can't continue with the command make. Check ~/sc/arx/build/CMakeFiles/CMakeError.log\n"
		exit 1
	fi
	make -j"$(getconf _NPROCESSORS_ONLN)"
}

install_binaries() {
	echo -e "\nInstalling binary files..."
	download_and_extract "$BINARY_URL" "$INSTALL_DIR"
	rm "$INSTALL_DIR/Arx Fatalis.sh"
	chmod +x "$INSTALL_DIR"/arx/arx*
	fix_libGLEW1.7
}

end_message() {
	echo -e "\nDone!. Click on Menu > Games > Arx Libertatis."
	runme
}

download_data_files() {
	download_and_extract "$DATA_URL" ~
}

choose_data_files() {
	while true; do
		dialog --clear \
			--title "[ Arx Libertatis Data files ]" \
			--menu "Choose language:" 11 68 3 \
			English "Install the game with English text and voices." \
			Spanish "Install the game with Spanish text and voices." \
			Exit "Continue with Shareware version" 2>"${INPUT}"

		menuitem=$(<"${INPUT}")

		case $menuitem in
		English) clear && DATA_URL=$(extract_url_from_file 7) && return 0 ;;
		Spanish) clear && DATA_URL=$(extract_url_from_file 6) && return 0 ;;
		Exit) clear ;;
		esac
	done
}

install() {
	mkdir -p "$INSTALL_DIR"
	installPackagesIfMissing "${PACKAGES[@]}"
	install_binaries
	generate_icon
	echo
	read -p "Do you have an original copy of Arx Fatalis (If not, a Shareware version will be installed) (y/N)?: " response
	if [[ $response =~ [Yy] ]]; then
		choose_data_files
		message_magic_air_copy
	fi

	download_data_files
	end_message
}

echo "Install Arx Libertatis (Port of Arx Fatalis)"
echo "============================================"
echo
echo " · Install path: $INSTALL_DIR/arx"
echo " · NOTE: It's NOT the latest compiled from source. This binary proceed from https://www.littlecarnage.com/"
echo " · I've tried to compile Arx Libertatis for 3 days with no success. I'll try it (or ptitSeb) in a long time."
echo
read -p "Press [Enter] to continue..."

install
