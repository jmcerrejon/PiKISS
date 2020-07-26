#!/bin/bash
#
# Description : Dolphin emulator 4.0 (Wii & Gamecube) thks to Kreal (krishenriksen.dk)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (23/Jul/20)
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

BINARY_PATH="https://www.dropbox.com/s/wu9n9g1x3hvtjxj/dolphin_rpi_experimental.tar.xz?dl=0"
CURRENT_PATH="${PWD}"

runme() {
	if [ ! -f /usr/local/bin/dolphin-emu ]; then
		echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
		exit_message
	fi
	read -p "Press [ENTER] to run the emulator..."
	/usr/local/bin/dolphin-emu
	exit_message
}

remove_files() {
	sudo rm -rf /usr/local/bin/dolphin-emu /usr/local/lib/libpolarssl.a "$HOME"/.dolphin-emu /usr/local/share/dolphin-emu /usr/local/share/pixmaps ~/.local/share/applications/dolphin.desktop
}

uninstall() {
	read -p "Do you want to uninstall Dolphin (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		remove_files
		if [[ -f /usr/local/bin/dolphin-emu ]]; then
			echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
			exit_message
		fi
		echo -e "\nSuccessfully uninstalled."
		exit_message
	fi
	exit_message
}

if [[ -f /usr/local/bin/dolphin-emu ]]; then
	echo -e "Dolphin already installed.\n"
	uninstall
fi

generate_icon() {
	echo -e "\nGenerating icon..."
	cp -f "$CURRENT_PATH"/res/dolphin.png /usr/local/share/dolphin-emu/dolphin.png
	if [[ ! -e ~/.local/share/applications/dolphin.desktop ]]; then
		cat <<EOF >~/.local/share/applications/dolphin.desktop
[Desktop Entry]
Name=Dolphin (Wii/Gamecube)
Exec=/usr/local/bin/dolphin-emu
Icon=/usr/local/share/dolphin-emu/dolphin.png
Type=Application
Comment=Dolphin is a Wii & Gamecube emulator. This release corresponds to release 4.0
Categories=Game;ActionGame;
EOF
	fi
}

download_binaries() {
	echo -e "\nInstalling binary files..."
	download_and_extract "$BINARY_PATH" /tmp
	move_files
}

move_files() {
	# Move to correspondent directory
	sudo mv -n /tmp/Dolphin/usr/local/bin/dolphin-emu /usr/local/bin/
	sudo mv -n /tmp/Dolphin/usr/local/lib/libpolarssl.a /usr/local/lib/
	sudo mv -n /tmp/Dolphin/usr/local/share/dolphin-emu /usr/local/share/
	sudo mv -n /tmp/Dolphin/usr/local/share/locale /usr/local/share/
	sudo mv -n /tmp/Dolphin/usr/local/share/pixmaps /usr/local/share/
	mv -f /tmp/Dolphin/.dolphin-emu "$HOME"/.dolphin-emu
	rm -rf /tmp/Dolphin
}

install() {
	echo -e "\n\nInstalling, please wait..."
	download_binaries
	generate_icon
	echo
	echo -e "Done!. You can play typing /usr/local/bin/dolphin-emu or opening the Menu > Games > Dolphin (Wii/Gamecube)."
	runme
}

echo "Install Dolphin emulator 4.0 - Wii & Gamecube (EXPERIMENTAL)"
echo "============================================================"
echo
echo " · Compiled version thanks to Kreal - krishenriksen.dk"
echo " · It's not the latest version. Developers stopped supporting 32-bit beyond 4.0."
echo

install
