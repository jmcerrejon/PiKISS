#!/bin/bash
#
# Description : RPiPlay - Airplay mirroring
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (21/Jul/20)
#
. ./scripts/helper.sh || . ../helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME"
BINARY_PATH="https://www.dropbox.com/s/049ps37hmukah0x/rplay-v1.2.tar.gz?dl=0"
INPUT=/tmp/rpiplay.$$

runme() {
	if [ ! -f "$INSTALL_DIR"/rpiplay/rpiplay ]; then
		echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
		exit_message
	fi
	read -p "Press [ENTER] to run the app..."
	"$INSTALL_DIR"/rpiplay/rpiplay
	exit_message
}

remove_files() {
	sudo rm -rf "$INSTALL_DIR"/rpiplay ~/.local/share/applications/rpiplay.desktop
}

uninstall() {
	read -p "Do you want to uninstall RPiPlay (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		sudo apt remove -y libavahi-compat-libdnssd1
		remove_files
		if [[ -e "$INSTALL_DIR"/rpiplay ]]; then
			echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
			exit_message
		fi
		echo -e "\nSuccessfully uninstalled."
		exit_message
	fi
	exit_message
}

if [[ -d "$INSTALL_DIR"/rpiplay ]]; then
	echo -e "RPiPlay already installed.\n"
	uninstall
	exit 1
fi

generate_icon() {
	if [[ ! -e ~/.local/share/applications/rpiplay.desktop ]]; then
		cat <<EOF >~/.local/share/applications/rpiplay.desktop
[Desktop Entry]
Name=rpiplay
Exec=/home/pi/rpiplay/rpiplay.sh
Icon=/home/pi/rpiplay/icon.png
Path=/home/pi/rpiplay/
Type=Application
Comment=An open-source implementation of an AirPlay mirroring server for the Raspberry Pi
Categories=ConsoleOnly;Utility;System;
Terminal=true
X-KeepTerminal=true
EOF
	fi
}

download_binaries() {
	echo -e "\nInstalling binary files..."
	download_and_extract "$BINARY_PATH" "$INSTALL_DIR"
}

end_message() {
	echo -e "\nSteps:\n======\n"
	echo "1) You will see a black background here. On your iDevice, open the Control Center by swiping up from the bottom of the device screen or swiping down from the top right corner of the screen (varies by device and iOS version)."
	echo "2) Tap the 'Screen Mirroring' or 'AirPlay' button and connect to RPiPlay."
	echo "3) EXIT: ALT + F4 or CTRL + C"
	echo -e "\n· More info rpiplay -h or visiting https://github.com/FD-/RPiPlay\n"
}

compile() {
	echo -e "\nInstalling dependencies (if proceed)...\n"
	sudo apt install -y cmake libavahi-compat-libdnssd-dev libplist-dev libssl-dev
	cd "$INSTALL_DIR"
	git clone https://github.com/FD-/RPiPlay.git rpiplay && cd "$_"
	mkdir build && cd "$_"
	cmake --DCMAKE_CXX_FLAGS="-O3" --DCMAKE_C_FLAGS="-O3" ..
	echo -e "\n\nCompiling...\n"
	make -j"$(getconf _NPROCESSORS_ONLN)" OPTOPT="-march=armv8-a+crc -mtune=cortex-a53"
	mv rpiplay ../rpiplay
	runme
}

install() {
	echo -e "\nInstalling dependencies (if proceed)...\n"
		if ! isPackageInstalled libavahi-compat-libdnssd1; then
		sudo apt install -y libavahi-compat-libdnssd1
	fi
	download_binaries
	generate_icon
	echo -e "\nDone. Type $INSTALL_DIR/rpiplay/rpiplay or go to Menu > System Tools > rpiplay.\n"
	end_message
	runme
}

menu() {
	while true; do
		dialog --clear \
			--title "[ RPiPlay ]" \
			--menu "Select from the list:" 11 68 3 \
			INSTALL "Binary (Recommended)" \
			COMPILE "Latest from source code. Estimated time on RPi 4: ~3 minutes." \
			Exit "Exit" 2>"${INPUT}"

		menuitem=$(<"${INPUT}")

		case $menuitem in
		INSTALL) clear && install ;;
		COMPILE) clear && compile ;;
		Exit) exit ;;
		esac
	done
}

menu

