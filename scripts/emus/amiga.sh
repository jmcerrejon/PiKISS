#!/bin/bash
#
# Description : Amiberry Amiga emulator
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.5.1 (05/Oct/20)
# Compatible  : Raspberry Pi 1-4
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"
PACKAGES=(libsdl2-image-2.0-0 libsdl2-ttf-2.0-0)
PACKAGES_DEV=(libsdl2-dev libguichan-dev libsdl2-ttf2.0-dev libsdl-gfx1.2-dev libxml2-dev libflac-dev libmpg123-dev)
RPI_MODEL=$(getRaspberryPiNumberModel)
AMIBERRY_BIN="https://github.com/midwan/amiberry/releases/download/v3.1.3.1/amiberry-rpi${RPI_MODEL}-sdl2-v3.1.3.1.zip"
GITHUB_PATH="https://github.com/midwan/amiberry.git"
KICK_FILE="https://misapuntesde.com/res/Amiga_roms.zip"
GAME="https://www.emuparadise.me/GameBase%20Amiga/Games/T/Turrican.zip"
ICON_URL="https://raw.githubusercontent.com/midwan/amiberry/master/data/amiberry.png"
INPUT=/tmp/amigamenu.$$

runme() {
	if [ ! -f "$INSTALL_DIR/amiberry/amiberry" ]; then
		echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
		exit_message
	fi
	read -p "Press [ENTER] to run..."
	cd "$INSTALL_DIR"/amiberry && ./amiberry
	exit_message
}

remove_files() {
	rm -rf "$INSTALL_DIR"/amiberry ~/.local/share/applications/amiberry.desktop
}

uninstall() {
	read -p "Do you want to uninstall Amiberry (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		remove_files
		if [[ -e "$INSTALL_DIR"/amiberry ]]; then
			echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
			exit_message
		fi
		echo -e "\nSuccessfully uninstalled."
		exit_message
	fi
	exit_message
}

if [[ -e $INSTALL_DIR/amiberry/amiberry ]]; then
	echo -e "Amiberry already installed.\n"
	uninstall
fi

post_install() {
	echo -e "\nPost install process. Just a moment...\n"
	cat <<EOF >"$INSTALL_DIR"/amiberry/amiberry.sh
#!/bin/bash
cd ${HOME}/games/amiberry && ./amiberry
EOF
	chmod +x "$INSTALL_DIR"/amiberry/amiberry.sh
	downloadROM
	downloadKICK
	mkDesktopEntry
	end_message
}

downloadKICK() {
	echo -e "\nCopying Rickstarts ROMs...\n"
	download_and_extract "$KICK_FILE" "$INSTALL_DIR"/amiberry/kickstarts
	mv "$INSTALL_DIR"/amiberry/kickstarts/kick13.rom "$INSTALL_DIR"/amiberry/kickstarts/kick.rom
}

downloadROM() {
	download_and_extract "$GAME" .
}

mkDesktopEntry() {
	wget -q "$ICON_URL" -O "$INSTALL_DIR"/amiberry/amiberry.png
	if [[ ! -e ~/.local/share/applications/amiberry.desktop ]]; then
		cat <<EOF >~/.local/share/applications/amiberry.desktop
[Desktop Entry]
Name=Amiberry
Exec=${INSTALL_DIR}/amiberry/amiberry.sh
Path=${INSTALL_DIR}/amiberry/
Icon=${INSTALL_DIR}/amiberry/amiberry.png
Type=Application
Comment=Amiga emulator port.
Categories=Game;
EOF
	fi
}

end_message() {
	echo -e "\n\nDone!. You can play typing $INSTALL_DIR/amiberry/amiberry or opening the Menu > Games > Amiberry.\n"
	runme
}

compile() {
	install_packages_if_missing "${PACKAGES_DEV[@]}"
	mkdir -p "$HOME"/sc && cd "$_"
	echo "Cloning and compiling repo..."
	git clone "$GITHUB_PATH" amiberry && cd "$_"
	if [ "$(uname -m)" == 'armv7l' ]; then
		make -j"$(nproc)" OPTOPT="-march=armv8-a+crc -mtune=cortex-a53"
	else
		make -j"$(nproc)" PLATFORM=rpi1
	fi
	downloadKICK
	echo -e "\nDone!. Compiled path: $HOME/sc/amiberry"
	exit_message
}

install() {
	echo "Amiberry for Raspberry Pi"
	echo "========================="
	echo
	echo " · More Info: https://github.com/midwan/amiberry"
	echo " · Kickstar ROMs & Turrican included."
	echo " · Install path: $INSTALL_DIR/amiberry"
	echo " · TIP: F12 = Menu."
	echo
	read -p "Press [ENTER] to continue..."
	install_packages_if_missing "${PACKAGES[@]}"
	download_and_extract "$AMIBERRY_BIN" "$INSTALL_DIR"/amiberry
	chmod +x "$INSTALL_DIR"/amiberry/amiberry
	post_install
}

menu() {

	while true; do
		dialog --clear \
			--title "[ Amiberry Amiga emulator for Raspberry Pi ]" \
			--menu "Select from the list:" 11 65 3 \
			INSTALL "Amiberry binary (Recommended)" \
			COMPILE "Compile Amiberry (latest). Time: ~22 minutes." \
			Exit "Exit" 2>"${INPUT}"

		menuitem=$(<"${INPUT}")

		case $menuitem in
		INSTALL) clear && install ;;
		COMPILE) clear && compile ;;
		Exit) exit ;;
		esac
	done
}

install
