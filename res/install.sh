#!/bin/bash
#
# Description : Easy install PiKISS
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.5 (8/Mar/23)
#
clear

readonly INSTALL_DIR="$HOME"
readonly PIKISS_URL="https://github.com/jmcerrejon/PiKISS.git"

make_desktop_entry() {
    if [[ ! -e "$HOME"/.local/share/applications/pikiss.desktop ]]; then
        echo -e "[Desktop Entry]\nName=PiKISS\nComment=A bunch of scripts with menu to make your life easier\nExec=${PWD}/piKiss.sh\nIcon=${PWD}/icons/pikiss_32.png\nTerminal=true\nType=Application\nCategories=ConsoleOnly;Utility;System;\nPath=${PWD}/" >"$HOME"/.local/share/applications/pikiss.desktop
        lxpanelctl restart
    fi
}

if [[ -d "$INSTALL_DIR/piKiss" ]]; then
    cd "$INSTALL_DIR/piKiss" && ./piKiss.sh
    exit 0
fi

install() {
    local IS_RASPBERRYPI
    IS_RASPBERRYPI=$(grep </proc/cpuinfo 'BCM2708\|BCM2709\|BCM2835\|BCM2711')
    cd "$INSTALL_DIR" || exit 1

    if [[ -z $IS_RASPBERRYPI ]]; then
        echo "Sorry. PiKISS is only available for Raspberry Pi 1-4 boards."
        exit
    fi
    echo -e "\nPiKISS\n======\n\nInstalling at ${INSTALL_DIR}/piKiss. Please wait...\n"
    sudo apt install -y dialog git
    git clone -b master "$PIKISS_URL" piKiss && cd "$_" || exit 1
}

install
make_desktop_entry
sleep 2
echo "
PiKISS installed!
=================

cd ${HOME}/piKiss, type or click ./piKiss.sh. You have an Menu shortcut, too!. Go to:

 · Raspberry Pi OS: Menu > System Tools > PiKISS
 · Twister OS: Menu > Accesories > PiKISS
"
read -p "Press ENTER to exit."
exit
