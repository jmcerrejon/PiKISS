#!/bin/bash
#
# Description : Moonlight-QT (WIP)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (13/Dec/20)
# Compatible  : Raspberry Pi 4 (tested)
#
# HELP		  : https://github.com/moonlight-stream/moonlight-docs/wiki/Installing-Moonlight-Qt-on-Raspberry-Pi-4
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly PACKAGES=(moonlight-qt)

runme() {
    if [ ! -f /usr/bin/moonlight-qt ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run..."
    /usr/bin/moonlight-qt
    exit_message
}

remove_files() {
    sudo apt remove -y moonlight-qt
    sudo apt -y autoremove
    [[ -e /etc/apt/sources.list.d/moonlight-raspbian.list ]] && sudo rm -rf /etc/apt/sources.list.d/moonlight-raspbian.list
    sudo apt update
}

uninstall() {
    read -p "Do you want to uninstall Moonlight-QT (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e /usr/bin/moonlight-qt ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -e /usr/bin/moonlight-qt ]]; then
    echo -e "Moonlight-QT is already installed.\n"
    uninstall
fi

pre_install() {
    echo "deb https://dl.bintray.com/moonlight-stream/moonlight-raspbian buster main" | sudo tee /etc/apt/sources.list.d/moonlight-raspbian.list 
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 379CE192D401AB61
    sudo apt update
}

end_message() {
    echo -e "\n\nDone!. You can play typing moonlight-qt or opening the Menu > Games > Moonlight."
    runme
}

install() {
    pre_install
    install_packages_if_missing "${PACKAGES[@]}"
    end_message
}

install_script_message
echo "
Moonlight Qt on Raspberry Pi 4 (WIP)
====================================

 · Moonlight PC is an open source implementation of NVIDIA's GameStream, as used by the NVIDIA Shield.
 · You need a PC with a GPU that supports nVIDIA GameStream.
 · I don't have a nVIDIA GameStream for test, so use it at your own risk.
 · If you don't get sound, try with: SDL_AUDIODRIVER=pulseaudio moonlight-qt
"
read -p "Continue (Y/n)? " response
if [[ $response =~ [Nn] ]]; then
    exit_message
fi

install
