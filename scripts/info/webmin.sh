#!/bin/bash
#
# Description : Webmin
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.0 (25/Apr/26)
# Tested      : Raspberry Pi 5
#
# shellcheck disable=SC1094
# shellcheck disable=SC1091
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

IP=$(get_ip)

uninstall() {
    read -p "Do you want to uninstall Webmin (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        [[ -e /etc/webmin/uninstall.sh ]] && sudo /etc/webmin/uninstall.sh
        sudo apt-get remove --purge -y webmin
        if [[ -e /usr/bin/webmin ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -e /usr/bin/webmin ]]; then
    echo -e "Webmin already installed.\n"
    uninstall
    exit 1
fi

setup() {
    curl -o /tmp/webmin-setup-repo.sh https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh
    sudo sh /tmp/webmin-setup-repo.sh
    rm /tmp/webmin-setup-repo.sh
}

install() {
	echo -e "\nInstalling Webmin\n=================\n\nPlease wait..."
	sudo apt-get install -y perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions libapt-pkg-perl python
	setup
    sudo apt -y --fix-broken install
    sudo apt-get install -y --install-recommends webmin usermin
    echo -e "Done!. Now you can go to https://${IP}:10000 on your web browser. Some extra info:\n · FAQ: https://webmin.com/faq/\n · User and password: Any user in the system"
    exit_message
}

install_script_message
echo "
Webmin
======

· Webmin is a web-based system administration tool.
· Go to https://${IP}:10000 on your web browser when installed.
· User and password: Any user in the system.
"

read -p "Do you want to install it? (y/N) " response
if [[ $response =~ [Nn] ]]; then
    exit_message
fi

install
