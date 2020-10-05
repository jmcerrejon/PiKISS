#!/bin/bash
#
# Description : Install Nagios4
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.1 (05/Oct/20)
# Compatible  : Raspberry Pi 1-4 (tested)
#
# TODO        : compile from source. Check https://pimylifeup.com/raspberry-pi-nagios/
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

PACKAGES=(nagios4)
PACKAGES_DEV=(autoconf build-essential wget unzip apache2 apache2-utils php libgd-dev snmp libnet-snmp-perl gettext libssl-dev wget bc gawk dc libmcrypt-dev)
IP=$(get_ip)
URL="http://${IP}/nagios"

post_install() {
    sudo usermod -a -G nagios www-data
    sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
    echo
    read -p "Do you want to reboot? (y/N) " response
    if [[ $response =~ [Yy] ]]; then
        sudo reboot
    fi
    exit_message
}

install() {
    echo
    echo -e "\nInstalling Nagios, please wait..."
    sudo apt-get -qq update
    sudo apt -y full-upgrade
    sudo dpkg-reconfigure tzdata
    install_packages_if_missing "${PACKAGES[@]}"
}

echo "Install Nagios 4"
echo "================"
echo
echo " · ~70 MB space occupied."
echo " · Once installed, this script can uninstall the app."
echo " · Nagios is a popular open-source software that is designed to monitor systems, networks, and infrastructure."
echo " · Installing on a modified system could overwrite any previous modifications."
echo " · When finish and reboot, you can browser to $URL"
echo
read -p "Are you sure you want to continue? (Y/n) " response

if [[ $response =~ [Nn] ]]; then
    exit_message
fi

install
post_install
