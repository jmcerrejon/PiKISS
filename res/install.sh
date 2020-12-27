#!/usr/bin/env bash
#
# Description : Easy install PiKISS
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.2 (08/Jul/20)
# TODO		  : Check the OS is Debian based.
clear

INSTALL_DIR="$HOME"

make_desktop_entry() {
    if [[ ! -e "$HOME"/.local/share/applications/pikiss.desktop ]]; then
        echo -e "[Desktop Entry]\nName=PiKISS\nComment=A bunch of scripts with menu to make your life easier\nExec=${PWD}/piKiss.sh\nIcon=${PWD}/icons/pikiss_32.png\nTerminal=true\nType=Application\nCategories=ConsoleOnly;Utility;System;\nPath=${PWD}/" >"$HOME"/.local/share/applications/pikiss.desktop
        lxpanelctl restart
    fi
}

cd "$INSTALL_DIR"

if [ -d "$INSTALL_DIR/piKiss" ]; then
    cd "$INSTALL_DIR/piKiss" && ./piKiss.sh
    exit
fi

if [[ ! $(cat /proc/cpuinfo | grep 'BCM2708\|BCM2709\|BCM2835\|BCM2711') ]]; then
    echo "Sorry. PiKISS is only for Raspberry Pi boards."
    exit
fi

echo -e "\nPiKISS\n======\n\nInstalling at ${INSTALL_DIR}/piKiss. Please wait...\n"
sudo apt install -y dialog
git clone https://github.com/jmcerrejon/PiKISS.git piKiss && cd "$_"
make_desktop_entry
sleep 3
echo -e "\n\nPiKISS installed ! .::. cd ${HOME}/piKiss, type or click ./piKiss.sh. You have an Menu shortcut, too! . Go to:\n\n · Raspberry Pi OS: Menu > System Tools > PiKISS\n\n · Twister OS: Menu > Accesories > PiKISS\n"
read -p "Press ENTER to exit."
exit
