
#!/bin/bash
#
# Description : CatacombGL
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (17/Jan/26)
# Tested      : Raspberry Pi 5
#
# shellcheck disable=SC1091
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly VERSION="0.5.7"
readonly PACKAGES=(libsdl2-2.0-0)
readonly PACKAGES_DEV=(cmake libsdl2-dev gcc pkg-config build-essential make)
readonly BINARY_64_BITS_URL="https://media.githubusercontent.com/media/jmcerrejon/pikiss-bin/refs/heads/main/games/catacombgl-$VERSION-rpi-aarch64.tar.gz"
readonly SOURCE_CODE_URL="https://github.com/ArnoAnsems/CatacombGL"
DATA_URL="https://archive.org/download/TheCatacombAbyss/CatacombAbyssTheV1.13sw1992softdiskPublishingaction.zip"

runme() {
	if [[ ! -f $INSTALL_DIR/catacombgl/CatacombGL ]]; then
		echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
		exit_message
	fi
	read -p "Press [ENTER] to run..."
	"$INSTALL_DIR/catacombgl/CatacombGL"
	exit_message
}

uninstall() {
	read -p "Do you want to uninstall CatacombGL (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		rm -rf "$INSTALL_DIR"/catacombgl ~/.config/CatacombGL ~/.local/share/applications/catacombgl.desktop
		if [[ -e "$INSTALL_DIR"/catacombgl ]]; then
			echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
			exit_message
		fi
		echo -e "\nSuccessfully uninstalled."
		exit_message
	fi
	exit_message
}

if [[ -d "$INSTALL_DIR"/catacombgl ]]; then
	echo -e "CatacombGL already installed.\n"
	uninstall
fi

generate_icon() {
	echo -e "\nGenerating icon..."
	if [[ ! -e ~/.local/share/applications/catacombgl.desktop ]]; then
		cat <<EOF >~/.local/share/applications/catacombgl.desktop
[Desktop Entry]
Name=CatacombGL
Exec=${INSTALL_DIR}/catacombgl/CatacombGL
Icon=${INSTALL_DIR}/catacombgl/CatacombGL.ico
Path=${INSTALL_DIR}/catacombgl/
Type=Application
Comment=CatacombGL is an open source port of the Catacomb 3D game engine.
Categories=Game;
EOF
	fi
}

compile() {
	echo -e "\nInstalling dependencies (if proceed)...\n"
	install_packages_if_missing "${PACKAGES_DEV[@]}"
	mkdir -p "$HOME/sc" && cd "$_" || exit 1
	git clone "$SOURCE_CODE_URL" CatacombGL && cd "$_" || exit 1
	mkdir -p build && cd "$_" || exit 1
	cmake ..
	echo -e "\nCompiling. Estimated time on RPi 5: ~10 minutes...\n"
	make_with_all_cores
	exit_message
}

post_install() {
    echo -e "\nDownloading CatacombGL data..."
    download_and_extract "$DATA_URL" "$INSTALL_DIR"/catacombgl/DATA
}

install() {
	echo -e "\nInstalling CatacombGL, please wait..."
	install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_64_BITS_URL" "$INSTALL_DIR"
    generate_icon
    post_install

	echo -e "\nDone!. You can play typing $INSTALL_DIR/catacombgl/CatacombGL or opening the Menu > Games > CatacombGL.\n"
	runme
}

install_script_message
echo "
CatacombGL
==========

· Open source port of the Catacomb 3D game engine.
· Version: $VERSION for aarch64.
· This script installs the demo version with Catacomb Abyss in the directory: $INSTALL_DIR/catacombgl/DATA
· Keyboard controls:
   * Arrow keys: Move
   * Mouse: Look around / Shoot
   * F1: Help
   * Esc: Menu
   * Z, X: Power
   * C: Heal
"

read -p "Press [Enter] to continue or [CTRL]+C to abort..."

install
