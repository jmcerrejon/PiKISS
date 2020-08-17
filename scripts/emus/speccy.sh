#!/bin/bash
#
# Description : Portable ZX-Spectrum emulator
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.5.2 (17/Aug/20)
# Compatible  : Raspberry 1-2 (¿?), Raspberry Pi 3-4 (tested)
#
clear

INSTALL_DIR="/home/$USER/games/speccy"
URL_FILE="https://misapuntesde.com/rpi_share/unreal_speccy_portable_0.0.86.11.tar.gz"
URL_GAME="https://www.mojontwins.com/juegos/mojon-twins--ninjajar-eng-v1.1.tap"

mkDesktopEntry() {
	if [[ ! -e /usr/share/applications/speccy.desktop ]]; then
        sudo wget https://quantum-bits.org/tango/icons/computer-sinclair-zx-spectrum.png -O /usr/share/pixmaps/spectrum.png
		sudo sh -c 'echo "[Desktop Entry]\nName=Speccy (ZX Spectrum)\nComment=Speccy emulates some versions of Sinclair ZX Spectrum.\nExec='"$INSTALL_DIR"'/unreal_speccy_portable\nIcon=/usr/share/pixmaps/spectrum.png\nTerminal=false\nType=Application\nCategories=Application;Game;\nPath='"$INSTALL_DIR"'/" > /usr/share/applications/speccy.desktop'
	fi
}

validate_url() {
    if [[ $(wget -S --spider "$1" 2>&1 | grep 'HTTP/1.1 200 OK') ]]; then echo "true"; fi
}

downloadROM() {
	wget -qO "$INSTALL_DIR"/ninjajar.tap "$URL_GAME"
}

playgame() {
    if [[ -f "$INSTALL_DIR"/ninjajar.tap ]]; then
        read -p "Do you want to play NinJaJar now? [y/n] " option
        case "$option" in
            y*) cd "$INSTALL_DIR" && ./unreal_speccy_portable ninjajar.tap ;;
        esac
    fi
}

install() {
	echo -e "\nInstalling, please wait...\n"
    if [[ ! -f "$INSTALL_DIR"/unreal_speccy_portable ]]; then
        mkdir -p "$HOME"/games && cd "$_"
        wget -qO- -O speccy.tar.gz "$URL_FILE" && tar -xzvf speccy.tar.gz && rm speccy.tar.gz
        cd speccy
		mkdir roms # It's neccessary, even it's empty
        downloadROM
        mkDesktopEntry
    fi
    echo -e "\nDone!. To play go to $INSTALL_DIR, copy any .tap file to directory and type: ./unreal_speccy_portable <game name>\n"
    playgame
    read -p "Press [Enter] to continue..."
    exit
}

compile_speccy() {
	sudo apt install -y libcurl4-openssl-dev libcurl4-gnutls-dev libcogl-gles2-dev git cmake libsdl2-dev
	cd ~ && git clone https://bitbucket.org/djdron/unrealspeccyp.git usp && cd usp/build/cmake
	cmake .. -DCMAKE_BUILD_TYPE=Release -DUSE_SDL=Off -DUSE_SDL2=On -DSDL2_INCLUDE_DIRS="/usr/inlude" -DCMAKE_CXX_FLAGS="$(sdl2-config --cflags)" -DCMAKE_EXE_LINKER_FLAGS="$(sdl2-config --libs)"
	make -j"$(getconf _NPROCESSORS_ONLN)"
	chmod +x unreal_speccy_portable
	mkdir roms # It's neccessary, even it's empty
}

echo -e "\nPortable ZX-Spectrum emulator (unrealspeccyp ver. 0.86.11)\n=========================================================\n\n\n· ESC to enter menu.\n· More Info: https://bitbucket.org/djdron/unrealspeccyp\n· Add Ninjajar by Mojon Twins.\n\nInstall path: $INSTALL_DIR\n"

install
