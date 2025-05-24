#!/bin/bash
#
# Description : Spelunky 1.1.4
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (20/Aug/20)
# Compatible  : Raspberry Pi 1-4 (tested)
#

. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

BINARY_PATH="https://github.com/yancharkin/SpelunkyClassicHDhtml5/releases/download/1.1.4/spelunky_classic_hd_html5-linux-armv7l.deb"

runme() {
    echo
    if [ ! -d "/opt/Spelunky Classic HD HTML5" ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "/opt/Spelunky Classic HD HTML5" && ./spelunky_classic_hd_html5
    clear
    exit_message
}

remove_files() {
    rm -rf ~/.config/SpelunkyClassicHD
}

uninstall() {
    read -p "Do you want to uninstall Spelunky (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo apt remove -y spelunkyclassichd
        remove_files
        if [[ -e "$INSTALL_DIR"/spelunky ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "/opt/Spelunky Classic HD HTML5" ]]; then
    echo -e "Spelunky already installed.\n"
    uninstall
    exit 0
fi

install() {
    echo -e "\nInstalling Spelunky Classic HD, please wait...\n"
    wget -q -P /tmp "$BINARY_PATH"
    sudo dpkg -i /tmp/spelunky_classic_hd_html5-linux-armv7l.deb
    sudo rm /tmp/spelunky_classic_hd_html5-linux-armv7l.deb
    echo -e "\nDone!. Press [Esc] inside the game to menu and change the language. Go to Menu > Games > Spelunky Classic HD HTML5"
}

install
runme
