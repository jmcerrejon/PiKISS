#!/bin/bash
#
# Description : OpenBOR
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.3.0 (29/Aug/20)
# Compatible  : Raspberry Pi 1-4 (tested)
# Repository  : https://github.com/crcerror/OpenBOR-63xx-RetroPie-openbeta
# Help		  : https://www.raspberrypi.org/forums/viewtopic.php?f=78&t=26859&start=25
# Help		  : https://www.raspberrypi.org/forums/viewtopic.php?f=78&t=26859&start=25
#             : https://retropie.org.uk/forum/topic/19326/openbor-6xxx-openbeta-testphase
#             : https://misapuntesde.com/post.php?id=567
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"
PACKAGES=(libsdl-gfx1.2-5 libpng12-0)
PACKAGES_DEV=(libsdl2-gfx-dev libvorbisidec-dev libvpx-dev libogg-dev libsdl2-gfx-1.0-0 libvorbisidec1)
BINARY_PATH="https://misapuntesde.com/res/openbor_by_ulysess.tar.gz"
GITHUB_PATH="https://github.com/crcerror/OpenBOR-Raspberry"
PLATFORM_ID=4

mkDesktopEntry() {
    if [[ ! -e ~/.local/share/applications/openbor.desktop ]]; then
        cat <<EOF >~/.local/share/applications/openbor.desktop
[Desktop Entry]
Name=OpenBOR
Exec=/home/pi/games/openbor/openbor_rpi
Icon=terminal
Type=Application
Comment=OpenBOR is the open source continuation of Beats of Rage, a Streets of Rage tribute game.
Categories=Game;ActionGame;
EOF
    fi
}

path_libsdl_gfx() {
    if [[ ! -e /usr/lib/arm-linux-gnueabihf/libSDL_gfx.so.13 ]]; then
        sudo ln -s /usr/lib/arm-linux-gnueabihf/libSDL_gfx.so.15 /usr/lib/arm-linux-gnueabihf/libSDL_gfx.so.13
    fi
}

install() {
    echo -e "\nInstalling, please wait..."
    installPackagesIfMissing "${PACKAGES[@]}"
    download_and_extract "$BINARY_PATH" "$INSTALL_DIR"
    mkDesktopEntry
    echo -e "\nDone!.\n· First copy pak files inside Paks directory and run ./unpack.sh\n· To play, run: $HOME/games/openbor/openbor_rpi"
    exit_message
}

compile() {
    installPackagesIfMissing "${PACKAGES_DEV[@]}"
    mkdir -p ~/sc && cd "$_"
    echo "Cloning and compiling repo..."
    [[ ! -d ~/sc/openbor ]] && git clone "$GITHUB_PATH"
    cd ~/sc/openbor/engine
    ./build.sh "$PLATFORM_ID"
}

echo "
OpenBOR for Raspberry Pi
========================

 · More Info: http://www.chronocrash.com/forum/
 · Optimized for Raspberry Pi 4.
 · Game included.
 · Install path: $INSTALL_DIR/openbor
"
read -p "Press [ENTER] to continue..."

install
