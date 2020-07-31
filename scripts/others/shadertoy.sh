#!/bin/bash
#
# Description : ShaderToy
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (31/Jul/20)
#
# Help        : https://github.com/Genymobile/scrcpy
#
. ./scripts/helper.sh || . ../helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/apps"
PACKAGES=( libsdl2-2.0-0 libsdl2-image-2.0-0 libsdl2-mixer-2.0-0 libsdl2-ttf-2.0-0 )
BINARY_PATH="http://www.skillmanmedia.com/ShaderToyRPi4b.zip"

runme() {
	if [ ! -d ${INSTALL_DIR}/ShaderToy ]; then
		echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
		exit_message
	fi
	read -p "Press [ENTER] to run..."
	cd ${INSTALL_DIR}/ShaderToy && ./ShaderToy
	exit_message
}

remove_files() {
	sudo rm -rf "$INSTALL_DIR"/ShaderToy ~/.local/share/applications/shadertoy.desktop
}

uninstall() {
	read -p "Do you want to uninstall ShaderToy (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		remove_files
		if [[ -e ${INSTALL_DIR}/ShaderToy ]]; then
			echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
			exit_message
		fi
		echo -e "\nSuccessfully uninstalled."
		exit_message
	fi
	exit_message
}

if [[ -d ${INSTALL_DIR}/ShaderToy ]]; then
	echo -e "ShaderToy already installed.\n"
	uninstall
	exit 1
fi

generate_icon() {
	if [[ ! -e ~/.local/share/applications/shadertoy.desktop ]]; then
		cat <<EOF >~/.local/share/applications/shadertoy.desktop
[Desktop Entry]
Name=ShaderToy
Exec=${INSTALL_DIR}/ShaderToy/ShaderToy
Icon=terminal
Path=${INSTALL_DIR}/ShaderToy/
Type=Application
Comment=Display and control of Android devices connected on USB
Categories=Utility;System;
EOF
	fi
}

download_binaries() {
	echo -e "\nInstalling binary files..."
	download_and_extract "$BINARY_PATH" "$INSTALL_DIR/ShaderToy"
}

install() {
	installPackagesIfMissing "${PACKAGES[@]}"
	download_binaries
	chmod +x "$INSTALL_DIR/ShaderToy/ShaderToy"
	generate_icon
	echo -e "\nDone. Type $INSTALL_DIR/ShaderToy/ShaderToy or go to Menu > System Tools > ShaderToy.\n"
}

echo "Install ShaderToy for Raspberry Pi 4"
echo "===================================="
echo
echo " · Note: This will ONLY work on the Raspberry Pi 4."
echo " · Small app that will render over 100+ OpenGL ES 3.0 shaders (pinched from ShaderToy.com)."
echo " · More info at: https://www.raspberrypi.org/forums/viewtopic.php?f=68&t=247036"
echo " · You need to reserve 128MB GPU."
echo " · Use the [SPACEBAR] to jump to the next shader and [ESCAPE] to exit."
echo " · There are some shaders that allow you to use the mouse (navigation/rotate etc..)."
echo " · The 'options.txt' file allows you to change a few obvious settings."
echo
read -p "Press [Enter] to continue..."

install
runme