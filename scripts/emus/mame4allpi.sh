#!/bin/bash
#
# Description : MAME for ALL
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.0 (7/May/21)
# Compatible  : Raspberry Pi 2-4
# Help		  : https://choccyhobnob.com/compiling-mame-on-raspberry-pi/
# TODO		  : Remove 32 or 64 bit files according with the OS host
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }
clear

readonly INSTALL_DIR="$HOME/games"
readonly BINARY_MAME_URL="https://misapuntesde.com/res/mame230_rpi.7z"
readonly PACKAGES_MAME=(p7zip)
readonly MAME4ALL_URL="https://github.com/squidrpi/mame4all-pi/releases/download/2018-09-11/mame4all_pi.zip"
readonly MAME4ALL_LOGO_URL="https://files10.com/wp-content/uploads/2018/10/MAME-Logo-Icon-48x48.png"
readonly ROMS_URL="https://misapuntesde.com/res/galaxian.zip"
readonly INPUT=/tmp/temp.$$

downloadROM() {
    echo -e "\nCopying ROM to $1..."
    [[ ! -d $1 ]] && mkdir -p "$1"
    download_file "$ROMS_URL" "$1"
}

# MAME

uninstall_mame() {
    if [[ ! -d $INSTALL_DIR/mame ]]; then
        return 0
    fi
    read -p "Do you want to uninstall MAME (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR/mame" ~/.local/share/applications/mame.desktop
        if [[ -e $INSTALL_DIR/mame ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

generate_icon_mame() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/mame.desktop ]]; then
        cat <<EOF >~/.local/share/applications/mame.desktop
[Desktop Entry]
Name=MAME
Version=1.0
Type=Application
Comment=Multiple Arcade Machine Emulator
Exec=${INSTALL_DIR}/mame/mame0230
Icon=${INSTALL_DIR}/mame/logo.png
Path=${INSTALL_DIR}/mame/
Terminal=false
Categories=Game;Emulator;
EOF
    fi
}

mame_install() {
    uninstall_mame
    echo "
MAME 230
========

· 32 and 64 bits.
· More info: https://stickfreaks.com/misc/raspberry-pi-mame-benchmarks | https://www.mamedev.org/?p=497
· KEYS: F3=RESET | F7=Load | Shift+F7=Save | 5=Add 1 Credit Player 1 | 1=Start Player 1 | ESC=Exit
"
    install_packages_if_missing "${PACKAGES[@]}"
    mkdir -p "$INSTALL_DIR" && cd "$_" || exit 1
    download_and_extract "$BINARY_MAME_URL" "$INSTALL_DIR"
    downloadROM "$INSTALL_DIR/mame/roms"
    generate_icon_mame
    echo -e "\nDone!. To play, go to /home/pi/mame and run the binary or on Desktop, Menu > games > MAME (Link to 32 bits version)."
    exit_message
}

# MAME4ALL

uninstall_mame4allpi() {
    if [[ ! -d $INSTALL_DIR/mame4allpi ]]; then
        return 0
    fi
    read -p "Do you want to uninstall MAME4All (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR/mame4allpi" ~/.local/share/applications/mame4allpi.desktop
        if [[ -e $INSTALL_DIR/mame4allpi ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

generate_icon_mame4allpi() {
    echo -e "\nGenerating icon..."
    download_file "$MAME4ALL_LOGO_URL" "$INSTALL_DIR/mame4allpi"
    if [[ ! -e ~/.local/share/applications/mame4allpi.desktop ]]; then
        cat <<EOF >~/.local/share/applications/mame4allpi.desktop
[Desktop Entry]
Name=MAME4AllPi
Version=1.0
Type=Application
Comment=Multiple Arcade Machine Emulator
Exec=${INSTALL_DIR}/mame4allpi/mame
Icon=${INSTALL_DIR}/mame4allpi/MAME-Logo-Icon-48x48.png
Path=${INSTALL_DIR}/mame4allpi/
Terminal=false
Categories=Game;Emulator;
EOF
    fi
}

mame4all_install() {
    uninstall_mame4allpi
    install_script_message
    mkdir -p "$INSTALL_DIR" && cd "$_" || exit 1
    download_and_extract "$MAME4ALL_URL" "$INSTALL_DIR/mame4allpi"
    generate_icon_mame4allpi
    downloadROM "$INSTALL_DIR/mame4allpi/roms"
    echo -e "\nDone!. To play, on Desktop Menu > games or go to $INSTALL_DIR/mame4allpi path, copy any rom to /roms directory and type: ./mame"
    exit_message
}

menu() {
    while true; do
        dialog --clear \
            --title "[ MAME For Raspberry PI ]" \
            --menu "Select from the list:" 11 132 16 \
            MAME230 "(Recommended) MAME 0.230" \
            MAME4ALL "Perfect for Debian Jessie. Outdated (2015). Emulates 2270 different 0.375b5 romsets." \
            Exit "Exit" 2>"${INPUT}"

        menuitem=$(<"${INPUT}")

        case $menuitem in
        MAME230) clear && mame_install ;;
        ADVANCED_MAME) clear && advmame_install ;;
        MAME4ALL) clear && mame4all_install ;;
        Exit) exit ;;
        esac
    done
}

menu
