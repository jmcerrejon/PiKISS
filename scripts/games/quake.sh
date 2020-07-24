#!/bin/bash
#
# Description : Quake ][ (I & III is coming)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (4/Apr/20)
# Compatible  : Raspberry Pi 4 (tested)
#
# HELP
#             · Quake 1: https://github.com/welford/qurp
#             · QuakeServer: https://www.recantha.co.uk/blog/?p=9962
#             · Darkplaces Quake: https://github.com/petrockblog/RetroPie-Setup/tree/master/scriptmodules/ports
#             · https://www.raspberrypi.org/forums/viewtopic.php?f=78&t=18853
#             · https://www.raspberrypi.org/forums/viewtopic.php?f=78&t=54683
#             · https://forums.steampowered.com/forums/showthread.php?t=996272 | https://quake.wikia.com/wiki/Quake_2_Soundtrack
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"
Q2_CONFIG_DIR="$HOME/.yq2"
Q1_PAK_URL="https://www.quakeforge.net/files/quake-shareware-1.06.zip"

Q2_BINARY_URL="https://www.dropbox.com/s/wrqzgicvb3ygmgh/yquake2_bin_arm.tar.gz?dl=0"
Q2_SC_URL="https://github.com/yquake2/yquake2.git"
Q2_PAK_URL="https://www.dropbox.com/s/sbr0xwr9wo9been/baseq2s.zip?dl=0"
Q2_OGG_URL="https://www.dropbox.com/s/z7c8lm8weemf2iy/q2_ogg.zip?dl=0"
Q2_HIGH_TEXTURE_PAK_URL="https://deponie.yamagi.org/quake2/texturepack/q2_textures.zip"
Q2_HIGH_TEXTURE_MODELS_URL="https://deponie.yamagi.org/quake2/texturepack/models.zip"

Q3_DEMO_PAK_URL="https://joshua14.homelinux.org/downloads/Q3-Demo-Paks.zip"

quake2_runme() {
	if [ ! -f "$INSTALL_DIR"/yquake2/quake2 ]; then
		echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
		exit_message
	fi
	read -p "Press [ENTER] to run the game..."
	"$INSTALL_DIR"/yquake2/quake2
	exit_message
}

quake2_remove_files() {
	rm -rf "$INSTALL_DIR"/yquake2 ~/.local/share/applications/yquake2.desktop $HOME/.yq2
}

quake2_uninstall() {
	read -p "Do you want to uninstall Quake ][ (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		quake2_remove_files
		if [[ -e "$INSTALL_DIR"/yquake2 ]]; then
			echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
			exit_message
		fi
		echo -e "\nSuccessfully uninstalled."
		exit_message
	fi
	exit_message
}

if [[ -d "$INSTALL_DIR"/yquake2 ]]; then
	echo -e "Diablo 2 already installed.\n"
	quake2_uninstall
fi

generate_icon() {
	echo -e "\nGenerating icon..."
	if [[ ! -e ~/.local/share/applications/yquake2.desktop ]]; then
		cat <<EOF >~/.local/share/applications/yquake2.desktop
[Desktop Entry]
Name=Quake ][
Exec=${INSTALL_DIR}/yquake2/quake2
Icon=${INSTALL_DIR}/yquake2/quake2.svg
Path=${INSTALL_DIR}/yquake2/
Type=Application
Comment=Yamagi Quake II is an enhanced client for id Software's Quake II with focus on offline and coop gameplay.
Categories=Game;ActionGame;
EOF
	fi
}

move_quake2_config_files() {
	mv -f "$INSTALL_DIR"/yquake2/.yq2 ~/
}

install_quake2_binary() {
	echo -e "\nInstalling binary files..."
	download_and_extract "$Q2_BINARY_URL" "$INSTALL_DIR"
	move_quake2_config_files
}

install_quake2_data() {
	echo -e "\nInstalling data files..."
	download_and_extract "$Q2_PAK_URL" "$Q2_CONFIG_DIR"
}

quake2_compile() {
	echo -e "\nInstalling Dependencies..."
	sudo apt install -y libsdl2-dev libopenal-dev
	mkdir -p "$HOME"/sc
	git clone "$Q2_SC_URL" yquake2 && cd "$_"
	# TODO Add on Makefile -march=armv7
	make -j"${CORES}"
	echo -e "\nDone!. "
}

quake2_soundtrack_download() {
	echo -e "\nInstalling sound tracks..."
	download_and_extract "$Q2_OGG_URL" "$Q2_CONFIG_DIR"/baseq2
}

quake2_high_textures_download() {
	echo -e "\nInstalling high texture pack..."
	download_and_extract "$Q2_HIGH_TEXTURE_PAK_URL" "$Q2_CONFIG_DIR"/baseq2
	echo "Installing high texture models..."
	download_and_extract "$Q2_HIGH_TEXTURE_MODELS_URL" "$Q2_CONFIG_DIR"/baseq2
}

quake2_end_message() {
	echo -e "\n\nDone!. You can play typing $INSTALL_DIR/yquake2/yquake2 or opening the Menu > Games > Quake ][.\n"
	quake2_runme
}

quake2_install() {
	echo -e "\n\nInstalling Quake ][, please wait...\n"
	mkdir -p "$INSTALL_DIR"
	install_quake2_binary
	quake2_soundtrack_download
	quake2_high_textures_download
	generate_icon
	echo
	read -p "Do you have an original copy of Quake ][ (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		Q2_PAK_URL=$(extract_url_from_file 5)
		message_magic_air_copy
		install_quake2_data
		quake2_end_message
	fi

	install_quake2_data
	quake2_end_message
}

echo "Install Quake ]["
echo "================"
echo
echo " · Start at 720p (You can change it) with OpenGL 1.4."
echo " · High textures."
echo " · OGG soundtrack."
echo " · Install path: $INSTALL_DIR/yquake2"
echo
read -p "Press [Enter] to install the game..."

quake2_install
