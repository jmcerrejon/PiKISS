#!/bin/bash
#
# Description : TIC-80 TINY COMPUTER
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (23/Aug/20)
# Compatible  : Raspberry Pi 3-4 (tested)
# Repository  : https://github.com/nesbox/TIC-80
#               https://github.com/hpingel/TIC-80.git
#
# Help        : ld -lbcm_host --verbose
#               https://github.com/nesbox/TIC-80/issues/984
#               https://github.com/nesbox/TIC-80/issues/1017
#               link_directories(/opt/vc/lib) on CMakeLists.txt
# Missing     : immintrin.h strlcpy _strrev _strlwr itoa _ltoa _stricmp _strnicmp wcslcat wcslcpy sysctlbyname iconv_open alloca dlopen samplerate.h bcm_host brcmegl fcitx/frontend.h
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/apps"
BINARY_PATH="https://misapuntesde.com/res/tic-80-0.182-dev_bin.tar.gz"
GITHUB_PATH="https://github.com/nesbox/TIC-80.git"
PACKAGES=(libibus-1.0-5 liblua5.3)
PACKAGES_DEV=(cmake libgtk-3-dev libglvnd-dev libglu1-mesa-dev libsdl2-dev zlib1g-dev liblua5.3-dev libgif-dev freeglut3-dev libunwind-dev libbsd0 libaudio-dev)

runme() {
    if [ ! -f "$INSTALL_DIR/tic-80/tic80" ]; then
		echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
		exit_message
	fi
    echo
	read -p "Press [ENTER] to run..."
	cd "$INSTALL_DIR"/tic-80 && ./tic80
	exit_message
}

remove_files() {
	rm -rf "$INSTALL_DIR"/tic-80 ~/.local/share/com.nesbox.tic
}

uninstall() {
	read -p "Do you want to uninstall TIC-80 (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		remove_files
		if [[ -e $INSTALL_DIR/tic-80/tic80 ]]; then
			echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
			exit_message
		fi
		echo -e "\nSuccessfully uninstalled."
		exit_message
	fi
	exit_message
}

if [[ -e $INSTALL_DIR/tic-80/tic80 ]]; then
	echo -e "TIC-80 already installed.\n"
	uninstall
fi

mkDesktopEntry() {
    echo -e "\nCreating shortcut icon..."
	if [[ ! -e ~/.local/share/applications/tic-80.desktop ]]; then
		cat <<EOF >~/.local/share/applications/tic-80.desktop
[Desktop Entry]
Name=TIC-80
Exec=${INSTALL_DIR}/tic-80/tic80
Path=${INSTALL_DIR}/tic-80/
Icon=${INSTALL_DIR}/tic-80/tic-80.png
Type=Application
Comment=TIC-80 is a tiny computer which you can use to make, play, and share tiny games.
Categories=Development;IDE;
EOF
	fi
}

install() {
    echo -e "\nInstalling, please wait...\n"
    sudo apt install -y "${PACKAGES[@]}"
    download_and_extract "$BINARY_PATH" "$INSTALL_DIR"
    create_libbcm_host_link
    mkDesktopEntry
    runme
}

create_libbcm_host_link() {
    if [ -f /usr/local/lib/libbcm_host.so ]; then
        return 0
    fi

    echo -e  "Creating link to /usr/local/lib/libbcm_host.so"
    # sudo ln -s /opt/vc/lib/libbcm_host.so /usr/local/lib/libbcm_host.so
    sudo cp /opt/vc/lib/libbcm_host.so /usr/local/lib
}

compile() {
    echo -e "\nDownloading and compiling, be patience..."
    [ -f ~/sc/TIC-80/build/CMakeFiles/CMakeError.log ] && rm ~/sc/TIC-80/build/CMakeFiles/CMakeError.log
    check_update
    sudo apt install -y "${PACKAGES_DEV[@]}"
    create_libbcm_host_link
    if [[ ! -d ~/sc/TIC-80 ]]; then
        mkdir -p ~/sc && cd "$_"
        git clone --recursive "$GITHUB_PATH"
    fi
    cd ~/sc/TIC-80/build
    cmake -DBUILD_PRO=true -Wno-dev ..
    if [[ -f ~/sc/TIC-80/build/CMakeFiles/CMakeError.log ]]; then
        echo
        read -p "Error!. Press [ENTER] to see the CMakeError.log"
        less ~/sc/TIC-80/build/CMakeFiles/CMakeError.log
        exit 1
    fi
    makeWithAllCores
    read -p "\nDone!. Check directory /bin if all goes OK."
    exit 0
}

echo "
TIC-80 for Raspberry Pi
=======================

 · ONLY WORKS on Twister-OS (For now).
 · Version 0.80-1280-dev.
 · There are built-in tools for development: code, sprites, maps & sound editors.
 · More Info: https://tic.computer/learn | https://github.com/nesbox/TIC-80/wiki
 · App Store for download games, demos, etc. at: https://tic80.com/play
 · Install path: $INSTALL_DIR/tic-80
 · Go to Menu > Programming (Development on Twister-OS) > TIC-80.
 · F11 = Full screen.
 
"
read -p "Press [ENTER] to continue..."

install
