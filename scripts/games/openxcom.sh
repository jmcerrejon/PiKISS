#!/bin/bash
#
# Description : OpenXcom with the help of user chills340
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (01/Aug/20)
# Compatible  : Raspberry Pi 4 (tested)
#
# Help		  : https://www.ufopaedia.org/index.php/Compiling_with_CMake_(OpenXcom)
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"
PACKAGES=( libsdl-gfx1.2-5 libglu1-mesa libyaml-cpp0.6 )
PACKAGES_DEV=(build-essential libboost-dev libsdl1.2-dev libsdl-mixer1.2-dev libsdl-image1.2-dev libsdl-gfx1.2-dev libyaml-cpp-dev xmlto)
BINARY_PATH="https://www.dropbox.com/s/z6ch5jp5zopghrf/openxcom_rpi.tar.gz?dl=0"
GITHUB_PATH="https://github.com/SupSuper/OpenXcom.git"
INPUT=/tmp/openxcom.$$

runme() {
	if [ ! -f "$INSTALL_DIR"/openxcom/openxcom ]; then
		echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
		exit_message
	fi
	read -p "Press [ENTER] to run the game..."
	cd "$INSTALL_DIR"/openxcom && ./openxcom
	exit_message
}

remove_files() {
	rm -rf "$INSTALL_DIR"/openxcom ~/.local/share/applications/openxcom.desktop ~/.config/openxcom
}

uninstall() {
	read -p "Do you want to uninstall OpenXcom (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		remove_files
		if [[ -e "$INSTALL_DIR"/openxcom ]]; then
			echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
			exit_message
		fi
		echo -e "\nSuccessfully uninstalled."
		exit_message
	fi
	exit_message
}

if [[ -d "$INSTALL_DIR"/openxcom ]]; then
	echo -e "openxcom already installed.\n"
	uninstall
fi

generate_icon() {
	echo -e "\nGenerating icon..."
	if [[ ! -e ~/.local/share/applications/openxcom.desktop ]]; then
		cat <<EOF >~/.local/share/applications/openxcom.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=OpenXcom
Comment=Open-source clone of UFO: Enemy Unknown
Exec=${INSTALL_DIR}/openxcom/openxcom
Icon=${INSTALL_DIR}/openxcom/openxcom.svg
Path=${INSTALL_DIR}/openxcom/
Terminal=false
Categories=Game;StrategyGame;
EOF
	fi
}

download_data_files() {
	local DATA_PATH
	DATA_PATH=$(extract_url_from_file 8)

	message_magic_air_copy
	download_and_extract "$DATA_PATH" /tmp
	cd /tmp/X-Com\ -\ UFO\ Enemy\ Unknown/
	mv ufo UFO && mv -f UFO "$1" && cd "$_"
	rm  -rf /tmp/X-Com\ -\ UFO\ Enemy\ Unknown
}

end_message() {
	echo -e "\n\nDone!. You can play typing $INSTALL_DIR/openxcom/openxcom or opening the Menu > Games > OpenXcom.\n"
}

compile() {
	installPackagesIfMissing "${PACKAGES_DEV[@]}"
	mkdir -p "$HOME/sc" && cd "$_"
	git clone "$GITHUB_PATH" openxcom && cd "$_"
	mkdir build && cd "$_"
	cmake -DCMAKE_BUILD_TYPE=Release ..
	makeWithAllCores "\nCompiling..."
	read -p "Do you want to install globally the game (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		sudo make install
	fi
	echo -e "\nDone!. Check the code at $HOME/sc/openxcom."
	exit_message
}

download_binaries() {
	echo -e "\nInstalling binary files..."
	download_and_extract "$BINARY_PATH" "$INSTALL_DIR"
}

install() {
	installPackagesIfMissing "${PACKAGES[@]}"
	download_binaries
	generate_icon
	echo
	read -p "Do you have an original copy of X-Com:Enemy Unknow (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		download_data_files "$INSTALL_DIR/openxcom"
		end_message
		runme
	fi

	echo -e "\nCopy the data files inside $INSTALL_DIR/openxcom/UFO."
	end_message
	exit_message
}

menu() {
	while true; do
		dialog --clear \
			--title "[ OpenXcom ]" \
			--menu "Select from the list:" 11 70 3 \
			INSTALL "Binary (Recommended)" \
			COMPILE "Latest from source code. Estimated time Rpi 4: ~10 min." \
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
