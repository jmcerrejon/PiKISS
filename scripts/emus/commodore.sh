#!/bin/bash
#
# Description : VICE Commodore 64
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (28/Aug/20)
# Compatible  : Raspberry Pi 4
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"
PACKAGES_DEV=(subversion autoconf flex bison xa65 libasound2-dev libsdl2-dev texinfo libglew-dev libieee1284-3-dev)
BINARY_PATH="https://misapuntesde.com/rpi_share/vice-3.4-bin-rpi.tar.gz"
SUBVERSION_PATH="svn://svn.code.sf.net/p/vice-emu/code/tags/v3.4/"

runme() {
    if [ ! -f "$INSTALL_DIR/vice/x64" ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run Old Tower (Directional Keys = OPQA)..."
    cd "$INSTALL_DIR"/vice && ./x64 -autostartprgmode 1 IMAGES/prg/ot64.prg
    exit_message
}

remove_files() {
    [[ -d "$INSTALL_DIR"/vice ]] && rm -rf "$INSTALL_DIR"/vice ~/.config/vice ~/.local/share/applications/vice.desktop
}

uninstall() {
    read -p "Do you want to uninstall VICE (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/vice ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -e $INSTALL_DIR/vice ]]; then
    echo -e "vice already installed.\n"
    uninstall
fi

mkDesktopEntry() {
    if [[ ! -e ~/.local/share/applications/vice.desktop ]]; then
        cat <<EOF >~/.local/share/applications/vice.desktop
[Desktop Entry]
Name=VICE
Exec=${INSTALL_DIR}/vice/x64
Path=${INSTALL_DIR}/vice/
Icon=${INSTALL_DIR}/vice/icon.png
Type=Application
Comment=VICE emulates the C64, the C64DTV, the C128, the VIC20, practically all PET models, the PLUS4 and the CBM-II (aka C610/C510). An extra emulator is provided for C64 expanded with the CMD SuperCPU.
Categories=Game;Emulator;
EOF
    fi
}

end_message() {
    echo -e "\n\nDone!. You can play typing $INSTALL_DIR/vice/x64 or opening the Menu > Games > VICE.\n"
    runme
}

compile() {
    installPackagesIfMissing "${PACKAGES_DEV[@]}"
    mkdir -p ~/sc && cd "$_"
    echo "Cloning and compiling repo..."
    [[ ! -d ~/sc/v3.4 ]] && svn checkout "$SUBVERSION_PATH"
    cd ~/sc/v3.4/vice
    make distclean
    ./autogen.sh
    ./configure --prefix="$INSTALL_DIR"/vice --enable-sdlui2 --without-oss --disable-ethernet --disable-catweasel --without-pulse --enable-x64 -–with-x -–without-resid -–disable-midi --disable-rs232 --disable-ipv6
    make_with_all_cores "-march=armv8-a+crc -mtune=cortex-a53"
    echo -e "\nDone!. Get the ROMs and check the directory $HOME/sc/v3.4/vice/src"
    exit_message
}

install() {
    download_and_extract "$BINARY_PATH" "$INSTALL_DIR"
    mkDesktopEntry
    end_message
}

echo "
VICE 3.4 for Raspberry Pi
=========================

 · More Info: https://vice-emu.sourceforge.io | https://www.c64-wiki.com/wiki/Main_Page
 · Optimized for Raspberry Pi 4 with the next parameters for better performante: SDL2 GUI, Disable Ethernet, Disable MIDI, Joystick support.
 · ROMs & 2 Games included: Old Tower (IMAGES/prg/ot64) & Santron (IMAGES/prg/santron.prg)
 · Install path: $INSTALL_DIR/vice
 · TIP: F12 = Menu.
"
read -p "Press [ENTER] to continue..."

install
