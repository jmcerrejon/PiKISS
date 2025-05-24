#!/bin/bash
#
# Description : Install Printer Server (cups)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (1/Nov/21)
#
. ../helper.sh || . ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }
clear

readonly PACKAGES=(cups)
IP=$(get_ip)
CUPS_PATH="/usr/lib/cups"

uninstall() {
    read -p "Cups already installed. Do you want to uninstall? (Y/n) " response
    if [[ $response =~ [Nn] ]]; then
        exit_message
    fi

    sudo apt-get purge -y cups
    sudo apt-get autoremove -y
    sudo apt-get autoclean
    sudo apt-get clean
    echo -e "\nDone."
    exit_message
}

if [[ -e $CUPS_PATH ]]; then
    uninstall
fi

allow_remote_machines() {
    echo
    read -p "Do you want to allow server admin from remote machines (y/n): " response
    if [[ $response =~ [Nn] ]]; then
        return 0
    fi

    sudo cupsctl --remote-any --remote-admin --share-printers --user-cancel-any
    sudo service cups restart
}

install() {
    echo -e "\nInstalling cups (74.4 MB aprox.)\n================================\n"

    install_packages_if_missing "${PACKAGES[@]}"
    sudo usermod -a -G lpadmin "$USER"
    allow_remote_machines
    echo -e "\nDone!. Now you can browser to http://$IP:631"
}

install_script_message
install
exit_message
