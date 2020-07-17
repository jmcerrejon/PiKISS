#!/bin/bash
#
# Description : scrcpy thks to Pi Labs
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (17/Jul/20)
#
# Help        : https://github.com/Genymobile/scrcpy
#
. ./scripts/helper.sh || . ../helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME"
BINARY_PATH="https://www.dropbox.com/s/6r3w0bjr96tpct3/scrcpy-1.13.tar.gz?dl=0"

remove_files() {
	sudo rm -rf "$INSTALL_DIR"/scrcpy /usr/local/share/scrcpy ~/.local/share/applications/scrcpy.desktop
}

uninstall() {
	read -p "Do you want to uninstall Scrcpy (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		remove_files
		if [[ -e "$INSTALL_DIR"/scrcpy ]]; then
			echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
			exitMessage
		fi
		echo -e "\nSuccessfully uninstalled."
		exitMessage
	fi
	exitMessage
}

if [[ -d "$INSTALL_DIR"/scrcpy ]]; then
	echo -e "Scrcpy already installed.\n"
	uninstall
	exit 1
fi

generate_icon() {
	if [[ ! -e ~/.local/share/applications/scrcpy.desktop ]]; then
		cat <<EOF >~/.local/share/applications/scrcpy.desktop
[Desktop Entry]
Name=Scrcpy
Exec=/home/pi/scrcpy/android.sh
Icon=/home/pi/scrcpy/android.jpg
Path=/home/pi/scrcpy/
Type=Application
Comment=Display and control of Android devices connected on USB
Categories=ConsoleOnly;Utility;System;
EOF
	fi
}

download_binaries() {
	echo -e "\nInstalling binary files..."
	download_and_extract "$BINARY_PATH" "$INSTALL_DIR"
}

install_dependencies() {
	echo -e "\nInstalling dependencies (if proceed)...\n"
	if ! isPackageInstalled adb; then
		sudo apt install -y adb
	fi
	if ! isPackageInstalled ffmpeg; then
		sudo apt install -y ffmpeg
	fi
	if ! isPackageInstalled libsdl2-2.0-0; then
		sudo apt install -y libsdl2-2.0-0
	fi
}

install() {
	install_dependencies
	download_binaries
	sudo mkdir -p /usr/local/share/scrcpy
	sudo cp -f $HOME/scrcpy/scrcpy-server /usr/local/share/scrcpy/scrcpy-server
	sleep 3
	generate_icon
	echo -e "\nDone. Type "$INSTALL_DIR"/scrcpy/android.sh or go to Menu > System Tools > Scrcpy.\n"
	exitMessage
}

echo "Install Scrcpy"
echo -e "==============\n"
echo " · More info scrcpy --help or visiting https://github.com/Genymobile/scrcpy"
echo " · The Android device requires at least API 21 (Android 5.0)."
echo " · Make sure you enabled adb debugging on your device(s)."
echo " · On some devices, you also need to enable an additional option to control it using keyboard and mouse."
echo " · If you have issues, try to run the app a couple of times through Terminal."
echo
read -p "Press [Enter] to continue..."

install
