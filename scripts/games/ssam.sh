#!/bin/bash
#
# Description : Serious Sam 1 & 2
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.0 (26/Aug/20)
# Compatible  : Raspberry Pi 4 (tested)
#
# Help        : https://www.raspberrypi.org/forums/viewtopic.php?t=200458
#

. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"
BINARY_PATH="https://misapuntesde.com/rpi_share/ssam-bin-1.05-rpi4.tar.gz"
PACKAGES_DEV=(libsdl2-dev bison flex libogg-dev)
INPUT=/tmp/ssam.$$

runme_tfe() {
    echo
    if [ ! -f "$INSTALL_DIR"/ssam-tfe/Bin/ssam-tfe ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/ssam-tfe/Bin && ./ssam-tfe
    clear
    exit_message
}

runme_tse() {
    echo
    if [ ! -f "$INSTALL_DIR"/ssam-tse/ssam-tse.sh ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/ssam-tse && ./ssam-tse.sh
    clear
    exit_message
}

remove_files() {
    [ -d "$INSTALL_DIR/$1" ] && rm -rf "${INSTALL_DIR:?}/${1}" ~/.local/share/applications/"$1".desktop
}


uninstall() {
    read -p "Do you want to uninstall it (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files "$1"
        if [[ -e "$INSTALL_DIR/$1" ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
}

generate_icon_tfe() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/ssam-tfe.desktop ]]; then
        cat <<EOF >~/.local/share/applications/ssam-tfe.desktop
[Desktop Entry]
Name=Serious Sam The First Encounter
Exec=${HOME}/games/ssam-tfe/Bin/ssam-tfe
Icon=${HOME}/games/ssam-tfe/ssam-tfe.png
Path=${HOME}/games/ssam-tfe/Bin
Type=Application
Comment=Sam Serious Stone is chosen to use the Time-Lock in hopes that he will defeat Mental and change the course of history...
Categories=Game;ActionGame;
EOF
    fi
}

generate_icon_tse() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/ssam-tse.desktop ]]; then
        cat <<EOF >~/.local/share/applications/ssam-tse.desktop
[Desktop Entry]
Name=Serious Sam The Second Encounter
Exec=${HOME}/games/ssam-tse/ssam-tse.sh
Icon=${HOME}/games/ssam-tse/ssam-tse.png
Path=${HOME}/games/ssam-tse/Serious-Engine/Bin
Type=Application
Comment=After the events of The First Encounter, Serious Sam is seen traveling through space in the SSS Centerprice...
Categories=Game;ActionGame;
EOF
    fi
}

fix_libEGL() {
    if [[ -f /opt/vc/lib/libEGL.so ]]; then
        echo -e "\nFixing libEGL.so..."
        touch "$INSTALL_DIR"/ssam-tse/Serious-Engine/Bin/libEGL.so
    fi
}

install_binaries() {
    download_and_extract "$BINARY_PATH" "$INSTALL_DIR"
    echo -e "\nDone!. Now follow the instructions to copy data files from https://github.com/ptitSeb/Serious-Engine"
    exit_message
}

install_full_tfe() {
    clear && BINARY_PATH=$(extract_url_from_file 11)
    message_magic_air_copy
    download_and_extract "$BINARY_PATH" "$INSTALL_DIR"
    generate_icon_tfe
    echo -e "\nDone!. Go to $INSTALL_DIR/ssam-tse/Bin/ssam-tse or go to Menu > Games > Serious Sam The First Encounter."
    runme_tfe
}

install_full_tse() {
    clear && BINARY_PATH=$(extract_url_from_file 10)
    message_magic_air_copy
    download_and_extract "$BINARY_PATH" "$INSTALL_DIR"
    fix_libEGL
    generate_icon_tse
    echo -e "\nDone!. Go to $INSTALL_DIR/ssam-tse/ssam-tse.sh or go to Menu > Games > Serious Sam The Second Encounter."
    runme_tse
}

choose_data_files() {
    while true; do
        dialog --clear \
            --title "[ Serious Sam Data files ]" \
            --menu "Choose:" 11 68 3 \
            I "Serious Sam The First Encounter" \
            II "Serious Sam The Second Encounter" \
            Exit "Return to main menu" 2>"${INPUT}"

        menuitem=$(<"${INPUT}")

        case $menuitem in
        I) install_full_tfe && return 0 ;;
        II) install_full_tse && return 0 ;;
        Exit) exit 0 ;;
        esac
    done
}

install() {
    echo "
Install Serious Sam 1 or 2
==========================

 · Optimized for Raspberry Pi 4.
 · I want to thanks Pi Labs & ptitSeb for the help.
"
read -p "Do you have an original copy of Serious Sam (If not, only the binaries will be installed) (Y/n)?: " response
    if [[ $response =~ [Nn] ]]; then
        install_binaries
    fi

    choose_data_files
}

if [[ -d "$INSTALL_DIR"/ssam-tfe ]]; then
    echo -e "Serious Sam The First Encounter already installed.\n"
    uninstall ssam-tfe
fi

if [[ -d "$INSTALL_DIR"/ssam-tse ]]; then
    echo -e "Serious Sam The Second Encounter already installed.\n"
    uninstall ssam-tse
fi

if [[ -d "$INSTALL_DIR"/ssam ]]; then
    echo -e "Serious Sam engine already installed.\n"
    uninstall ssam
fi

install
