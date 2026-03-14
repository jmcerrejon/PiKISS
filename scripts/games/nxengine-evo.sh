#!/bin/bash
#
# Description : NxEngine Evo (AKA Cave Story) - A free and open source 2D game engine
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (14/Mar/26)
# Tested      : Raspberry Pi 5
#
# shellcheck disable=SC1091
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libsdl2-2.0-0)
readonly PACKAGES_DEV=(build-essential libpng-dev libjpeg-dev make cmake cmake-data git libsdl2-dev libsdl2-doc libsdl2-gfx-dev libsdl2-gfx-doc libsdl2-image-dev libsdl2-mixer-dev libsdl2-net-dev libsdl2-ttf-dev)
readonly BINARY_64_BITS_URL="https://media.githubusercontent.com/media/jmcerrejon/pikiss-bin/refs/heads/main/games/nxengine-evo-rpi-aarch64.tar.gz"
readonly SOURCE_CODE_URL="https://github.com/nxengine/nxengine-evo"

runme() {
	if [[ ! -f $INSTALL_DIR/nxengine-evo/nxengine-evo ]]; then
		echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
		exit_message
	fi
	read -p "Press [ENTER] to run..."
	"$INSTALL_DIR/nxengine-evo/nxengine-evo"
	exit_message
}

uninstall() {
	read -p "Do you want to uninstall NxEngine Evo (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		rm -rf "$INSTALL_DIR"/nxengine-evo ~/.config/NxEngineEvo ~/.local/share/applications/nxengine-evo.desktop
		if [[ -e "$INSTALL_DIR"/nxengine-evo ]]; then
			echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
			exit_message
		fi
		echo -e "\nSuccessfully uninstalled."
		exit_message
	fi
	exit_message
}

if [[ -d "$INSTALL_DIR"/nxengine-evo ]]; then
	echo -e "NxEngine Evo already installed.\n"
	uninstall
fi

generate_icon() {
	echo -e "\nGenerating icon..."
	if [[ ! -e ~/.local/share/applications/nxengine-evo.desktop ]]; then
		cat <<EOF >~/.local/share/applications/nxengine-evo.desktop
[Desktop Entry]
Type=Application
Terminal=false
Name=Cave story (NxEngine Evo)
GenericName=Jump-and-run Platformer Game
Comment=NxEngine Evo is an open source 2D game engine.
Exec=${INSTALL_DIR}/nxengine-evo/nxengine-evo
Icon=${INSTALL_DIR}/nxengine-evo/org.nxengine.nxengine_evo.png
Path=${INSTALL_DIR}/nxengine-evo/
Categories=Game;
EOF
	fi
}

compile() {
	echo -e "\nInstalling dependencies (if proceed)...\n"
	install_packages_if_missing "${PACKAGES_DEV[@]}"
	mkdir -p "$HOME/sc" && cd "$_" || exit 1
	git clone "$SOURCE_CODE_URL" NxEngineEvo && cd "$_" || exit 1
	mkdir -p build && cd "$_" || exit 1
	cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DPORTABLE=ON ..
	echo -e "\nCompiling. Estimated time on RPi 5: ~10 minutes...\n"
	make_with_all_cores
	exit_message
}


install() {
	echo -e "\nInstalling Cave story (NxEngine Evo), please wait..."
	install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_64_BITS_URL" "$INSTALL_DIR"
    generate_icon

	echo -e "\nDone!. You can play typing $INSTALL_DIR/nxengine-evo/nxengine-evo or opening the Menu > Games > Cave story (NxEngine Evo).\n"
	runme
}

install_script_message
echo "
Cave story (NxEngine Evo)
=========================

· A somewhat upgraded/refactored version of NXEngine by Caitlin Shaw.
· Fixed issue with resolutions of the game on Raspberry Pi.
· All game-sets are included in the package, so you can play right after the installation.
· Localized for English, Arabic, Chinese, French, German, Italian, Japanese, Korean, Polish, Russian, Spanish.
"

read -p "Press [Enter] to continue or [CTRL]+C to abort..."

install
