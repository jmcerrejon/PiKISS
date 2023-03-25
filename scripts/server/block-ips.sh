#!/bin/bash
#
# Description : Block access attempts to your Pi connected to the Internet
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (18/Mar/2023)
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }
clear

readonly PACKAGES=(ipset iptables)

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    ipset -q flush ipsum
    ipset -q create ipsum hash:net
    for ip in $(curl --compressed https://raw.githubusercontent.com/stamparm/ipsum/master/ipsum.txt 2>/dev/null | grep -v "#" | grep -v -E "\s[1-2]$" | cut -f 1); do ipset add ipsum "$ip"; done
    iptables -D INPUT -m set --match-set ipsum src -j DROP 2>/dev/null
    iptables -I INPUT -m set --match-set ipsum src -j DROP
}

install_script_message
echo "
Block IPs
=========

 · This script run as root.
 · Block access attempts to your Pi connected to the Internet.
"
read -p "Continue? (Y/n) " response
if [[ $response =~ [Nn] ]]; then
    exit_message
fi

install
