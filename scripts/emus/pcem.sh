#!/bin/bash
#
# Description : PCem Emulator
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.1 (19/Jun/24)
#
# shellcheck source=../helper.sh
. ../helper.sh || . ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/apps"
readonly VERSION="v17"
readonly PACKAGES=(libopenal1 libwxgtk3.2-1 libpcap0.8)
readonly PACKAGES_DEV=(libopenal-dev libwxgtk3.2-dev libpcap0.8-dev libsdl2-dev)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/pcem-$VERSION-aarch64.tar.gz"
readonly ROM_DATA_URL="https://archive.org/download/pcem-v-17-roms/PCem%20v17%20ROMs.zip" # Alternative: https://github.com/BaRRaKudaRain/PCem-ROMs/releases/download/v17.0/PCem_ROMs.7z
readonly SOURCE_CODE_URL="https://github.com/sarah-walker-pcem/pcem"
readonly FORUM_URL="https://pcem-emulator.co.uk/phpBB3/"

runme() {
    echo
    if [ ! -f "$INSTALL_DIR/pcem/pcem" ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run..."
    cd "$INSTALL_DIR/pcem" && ./pcem
    exit_message
}

uninstall() {
    read -p "Do you want to uninstall PCem (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        [[ -d $INSTALL_DIR/pcem ]] && rm -rf "$INSTALL_DIR/pcem" ~/.pcem ~/.local/share/applications/pcem.desktop
        if [[ -e "$INSTALL_DIR/pcem/pcem" ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -e $INSTALL_DIR/pcem/pcem ]]; then
    echo -e "PCem already installed.\n"
    uninstall
fi

make_desktop_entry() {
    if [[ ! -e ~/.local/share/applications/pcem.desktop ]]; then
        cat <<EOF >~/.local/share/applications/pcem.desktop
[Desktop Entry]
Name=PCem
Exec=${INSTALL_DIR}/pcem/pcem
Path=${INSTALL_DIR}/pcem/
Icon=${INSTALL_DIR}/pcem/pcem.png
Type=Application
Comment=PCem is an emulator for old XT/AT-class PCs.
Categories=Game;Emulator;
EOF
    fi
}

compile() {
    [[ -e $HOME/sc/pcem ]] && rm -rf "$HOME/sc/pcem"
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || return
    git clone "$SOURCE_CODE_URL" pcem && cd "$_" || return
    cmake -G "Ninja" -DCMAKE_BUILD_TYPE=RelWithDebInfo -DPCEM_RELDEB_AS_RELEASE=ON -DFORCE_X11=ON -DUSE_NETWORKING=ON -DUSE_PCAP_NETWORKING=ON -DSSE=OFF -DAESNI=ON -DUSE_EXPERIMENTAL=ON -DUSE_EXPERIMENTAL_PGC=ON -DUSE_ALSA=ON .
    echo -e "\nCompiling..."
    ninja
    echo -e "\nDone!. Check the binary at $HOME/sc/pcem/src/pcem."
    exit_message
}

post_install() {
    local PCEM_CONFIG_DIR="$HOME/.pcem"
    local ROM_PATH="$HOME/.pcem/roms"

    [[ ! -d $PCEM_CONFIG_DIR ]] && mv "$INSTALL_DIR/pcem/.pcem" "$HOME"
    if [[ -f $PCEM_CONFIG_DIR/pcem.cfg ]]; then
        echo -e "\nPatching config file..."
        sed -i "s/ulysess/$(whoami)/g" "$PCEM_CONFIG_DIR/pcem.cfg"
    fi

    echo
    read -p "Do you want to install ROMs for devices?. Take into account the laws in your country. [y/N] " response
    if [[ $response =~ [Yy] ]]; then
        [[ ! -d $ROM_PATH ]] && mkdir -p "$ROM_PATH"
        download_and_extract "$ROM_DATA_URL" "$ROM_PATH"
    fi
    runme
}

install() {
    echo -e "\nInstalling..."
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    make_desktop_entry
    post_install
    echo -e "\nDone!. To run, go to $INSTALL_DIR/pcem and type: ./pcem\n"
    runme
}

install_script_message
echo "
PCem Emulator
=============

· Version: $VERSION
· This script can install ROMs files (If you're not certain about the laws in your city, it's best to not install it).
· PCem Display Engine: wxWidgets
· Supported: Plugin, Networking, PCAP Networking. ALSA MIDI, Force X11 Mode on Wayland Systems, Experimental Modules (Professional Graphics Controller)
· SSE AESNI are disabled.
· More Info: $SOURCE_CODE_URL | $FORUM_URL
"
read -p "Press [ENTER] to install..."

install
