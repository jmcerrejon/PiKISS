#!/bin/bash
#
# Description : MAME for ALL
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.9 (17/Jun/20)
# Compatible  : Raspberry Pi 2-4
# Help		  : https://choccyhobnob.com/compiling-mame-on-raspberry-pi/
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }
clear

URL_MAME="https://choccyhobnob.com/dl/mame/mame0211b_rpi3.zip"
URL_ADVMAME="https://github.com/amadvance/advancemame/releases/download/v3.9/advancemame_3.9-1_armhf.deb"
URL_MAME4ALL="https://sourceforge.net/projects/mame4allpi/files/latest/download?source=files"
ROMS_URL="https://misapuntesde.com/res/galaxian.zip"

make_desktop_entry() {
    if [[ ! -e /usr/share/applications/mame.desktop ]]; then
        sudo wget https://img.app-island.com/article/22/34/icon.png -O /usr/share/pixmaps/mame.png
        sudo sh -c 'echo "[Desktop Entry]\nName=MAME\nComment=Multiple Arcade Machine Emulator\nExec='$HOME'/games/mame4allpi/mame\nIcon=/usr/share/pixmaps/mame.png\nTerminal=false\nType=Application\nCategories=Application;Game;\nPath='$HOME'/games/mame4allpi/" > /usr/share/applications/mame.desktop'
    fi
}

mame_install() {
    clear
    local INSTALL_DIR="$HOME/games/mame0211b_rpi3"
    if [[ -e $INSTALL_DIR ]]; then
        endMessage 'MAME by Choccy already installed. Skipping...'
        return 0
    fi
    sudo apt install -y libsdl2-dev libsdl2-ttf-2.0-0 libqt5widgets5
    mkdir -p $HOME/games && cd $_
    wget --user-agent="Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36" -O mame0211b_rpi3.zip $URL_MAME && unzip mame0211b_rpi3.zip && rm mame0211b_rpi3.zip
    downloadROM $INSTALL_DIR/roms
    endMessage "Done!. Type $INSTALL_DIR/mame0211b_rpi3 to Play"
}

advmame_install() {
    clear
    local INSTALL_DIR="$HOME/.advance/roms"
    if isPackageInstalled advancemame; then
        endMessage 'AdvancedMAME already installed. Skipping...'
        return 0
    fi
    wget -O /tmp/advancemame_3.9-1_armhf.deb $URL_ADVMAME
    sudo dpkg -i /tmp/advancemame_3.9-1_armhf.deb
    mkdir -p $INSTALL_DIR
    rm /tmp/advancemame_3.9-1_armhf.deb
    downloadROM $INSTALL_DIR
    endMessage "Done!. You need to exit from Desktop and type advmame. ROMs directory at ~/.advance/roms"
}

mame4all_install() {
    clear
    local INSTALL_DIR="$HOME/games/mame4allpi"
    if [[ -e $INSTALL_DIR ]]; then
        endMessage 'MAME4All already installed. Skipping...'
        return 0
    fi
    mkdir -p $INSTALL_DIR && cd $_
    wget -qO- -O $INSTALL_DIR/tmp.zip $URL_MAME4ALL && unzip -o $INSTALL_DIR/tmp.zip && rm $INSTALL_DIR/tmp.zip
    downloadROM $INSTALL_DIR/roms
    make_desktop_entry
    endMessage "Done!. To play, on Desktop Menu > games or go to $INSTALL_DIR path, copy any rom to /roms directory and type: ./mame"
}

downloadROM() {
    echo "Copying ROM to $1..."
    wget -qO- -O $1/galaxian.zip $ROMS_URL
}

endMessage() {
    read -p "$1. Press [ENTER] to continue..."
}

menu() {
    cmd=(dialog --separate-output --title "[ MAME For Raspberry PI ]" --checklist "Move with the arrows up & down. ESC to exit. Space to select the emulator you want to install:" 11 135 16)
    options=(
        MAME_Choccy "(Recommended) MAME for Rpi 3/4 originally stood for Multiple Arcade Machine Emulator compiled by Choccy (2019)." on
        ADVANCED_MAME "Version 3.9-1 2018/09. Not X Environment or Rpi 4 supported." off
        MAME4ALL "Based on Franxis MAME4ALL (MAME 0.37b5). Outdated (2015). Emulates 2270 different 0.375b5 romsets." off
    )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    for choice in $choices; do
        case $choice in
        MAME_Choccy) mame_install ;;
        ADVANCED_MAME) advmame_install ;;
        MAME4ALL) mame4all_install ;;
        esac
    done
}

menu
