#!/bin/bash
#
# Description : Easy install PiKISS
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.9 (12/Nov/23)
#
clear

readonly INSTALL_DIR="$HOME"
readonly PIKISS_URL="https://github.com/jmcerrejon/PiKISS.git"

make_desktop_entry() {
    if [[ ! -e "$HOME"/.local/share/applications/pikiss.desktop ]]; then
        echo -e "[Desktop Entry]\nName=PiKISS\nComment=A bunch of scripts with menu to make your life easier\nExec=${PWD}/piKiss.sh\nIcon=${PWD}/icons/pikiss_32.png\nTerminal=true\nType=Application\nCategories=ConsoleOnly;Utility;System;\nPath=${PWD}/" >"$HOME"/.local/share/applications/pikiss.desktop
        if [[ -e /usr/bin/lxpanelctl ]]; then
            echo -e "\nRestarting LXPanel..."
            lxpanelctl restart &>/dev/null
        fi
    fi
}

check_and_install_dialog() {
    if ! [ -x "$(command -v dialog)" ]; then
        read -p "Dialog pkg is not installed and you need it for PiKISS. Do you want to install it? (y/N) " response
        if [[ $response =~ [Yy] ]]; then
            sudo apt install -y dialog
        else
            echo "Aborting..."
            exit 1
        fi
    fi
}

if [[ -d "$INSTALL_DIR/piKiss" ]]; then
    check_and_install_dialog
    cd "$INSTALL_DIR/piKiss" && ./piKiss.sh
    exit 0
fi

install() {
    if ! grep -q </proc/device-tree/compatible 'bcm2712\|bcm2711\|bcm2837\|bcm2836\|bcm2835'; then
        echo "Sorry. PiKISS is only available for Raspberry Pi boards."
        exit 1
    fi

    echo -e "\nPiKISS\n======\n\nInstalling at ${INSTALL_DIR}/piKiss. Please wait...\n"
    cd "$INSTALL_DIR" || exit 1
    check_and_install_dialog
    git clone -b master "$PIKISS_URL" piKiss && cd "$_" || exit 1
}

install
make_desktop_entry
sleep 2
echo "
PiKISS installed!
=================

cd ${HOME}/piKiss, type ./piKiss.sh. You have a menu shortcut, too!. Go to:

 · Raspberry Pi OS: Menu > System Tools > PiKISS
"
read -p "Press ENTER to exit."
exit
