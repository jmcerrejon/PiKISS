#!/bin/bash
#
# Description : Install Printer Server (cups)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9 (12/Sep/16)
#
# IMPROVEMENT · Uninstall option if cups is detected
#
clear
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

check_update

USER=$(whoami)
IP=$(hostname -I)

allow_remote_machines(){
    sudo cupsctl --remote-any --remote-admin --share-printers --user-cancel-any
    sudo service cups restart
}

echo -e "Installing cups (74.4 MB aprox.)\n================================\n"
INSTALLER_DEPS=( cups )
check_dependencies $INSTALLER_DEPS
sudo usermod -a -G lpadmin $USER

read -p "Do you want to allow server admin from remote machines (y/n)?" option
case "$option" in
    y*) allow_remote_machines ;;
esac

read -p "Done!. Now you can browser to http://$IP:631 Press [Enter] to continue..."
