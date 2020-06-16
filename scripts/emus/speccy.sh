#!/bin/bash
#
# Description : Portable ZX-Spectrum emulator
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.5.0 (02/May/20)
# Compatible  : Raspberry Pi 4 (tested)
#
clear

INSTALL_DIR="/home/$USER/games/speccy"
URL_FILE="https://www.dropbox.com/s/uhpryw4su15fck0/unreal_speccy_portable_0.0.86.11.tar.gz?dl=0"

mkDesktopEntry() {
	if [[ ! -e /usr/share/applications/speccy.desktop ]]; then
        sudo wget https://quantum-bits.org/tango/icons/computer-sinclair-zx-spectrum.png -O /usr/share/pixmaps/spectrum.png
		sudo sh -c 'echo "[Desktop Entry]\nName=Speccy (ZX Spectrum)\nComment=Speccy emulates some versions of Sinclair ZX Spectrum.\nExec='$INSTALL_DIR'/unreal_speccy_portable\nIcon=/usr/share/pixmaps/spectrum.png\nTerminal=false\nType=Application\nCategories=Application;Game;\nPath='$INSTALL_DIR'/" > /usr/share/applications/speccy.desktop'
	fi
}

validate_url() {
    if [[ `wget -S --spider $1 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then echo "true"; fi
}

playgame() {
    if [[ -f $INSTALL_DIR/ninjajar.tap ]]; then
        read -p "Do you want to play NinJaJar now? [y/n] " option
        case "$option" in
            y*) cd $INSTALL_DIR && ./unreal_speccy_portable ninjajar.tap ;;
        esac
    fi
}

changeInstallDir() {
    echo "Enter new full path:"
    read INSTALL_DIR
    echo "New path: $INSTALL_DIR"
}

install() {
    if [[ ! -f $INSTALL_DIR/unreal_speccy_portable ]]; then
        mkdir -p $HOME/games && cd $HOME/games
        wget -qO- -O tmp.tar.gz $URL_FILE && tar -xzvf tmp.tar.gz && rm tmp.tar.gz
        cd speccy
        wget -O $INSTALL_DIR/ninjajar.tap https://www.mojontwins.com/juegos/mojon-twins--ninjajar-eng-v1.1.tap
        mkDesktopEntry
    fi
	clear
    echo "Done!. To play go to install path, copy any .tap file to directory and type: ./unreal_speccy_portable <game name>"
    playgame
    read -p "Press [Enter] to continue..."
    exit
}

compile_speccy() {
	sudo apt install -y libcurl4-openssl-dev libcurl4-gnutls-dev libcogl-gles2-dev git cmake libsdl2-dev
	cd ~ && git clone https://bitbucket.org/djdron/unrealspeccyp.git usp && cd usp/build/cmake
	# wget https://bitbucket.org/djdron/unrealspeccyp/raw/19bf453126d4d5c898000363dec922ee409be310/build/cmake/CMakeLists.txt
	cmake .. -DCMAKE_BUILD_TYPE=Release -DUSE_SDL=Off -DUSE_SDL2=On -DSDL2_INCLUDE_DIRS="/usr/inlude" -DCMAKE_CXX_FLAGS="`sdl2-config --cflags`" -DCMAKE_EXE_LINKER_FLAGS="`sdl2-config --libs`"
	make -j4
	chmod +x unreal_speccy_portable
}

echo -e "Portable ZX-Spectrum emulator (unrealspeccyp ver. 0.86.11)\n=========================================================\n\n· More Info: https://bitbucket.org/djdron/unrealspeccyp\n· Add Ninjajar\n\nInstall path: $INSTALL_DIR"
while true; do
    echo " "
    read -p "Is it right? [y/n] " yn
    case $yn in
    [Yy]* ) echo "Installing, please wait..." && install;;
    [Nn]* ) changeInstallDir;;
    [Ee]* ) exit;;
    * ) echo "Please answer (y)es, (n)o or (e)xit.";;
    esac
done
