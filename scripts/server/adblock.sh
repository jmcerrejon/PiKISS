#!/bin/bash
#
# Description : Pi-Hole
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (04/Nov/2020)
# Repository  : https://github.com/pi-hole
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }
clear

post_install() {
    echo
    echo "Now you can set your new DNS on all the devices and/or computers of your office/home, with the same IP provided by Pi-Hole."
    exit_message
}

install_script_message
echo "
Pi-Hole
=======

 · Turn Raspberry Pi into a network-wide ad blocker.
 · When ask you about Upstream DNS, I recommend you Cloudflare.
 · For log levels, check https://docs.pi-hole.net/ftldns/privacylevels/
 · If you want to change the password, type: pihole -a -p
 · The Pi-hole is free, but powered by your donations: https://pi-hole.net/donate/
"
read -p 'Press [ENTER] to continue...'

curl -sSL https://install.pi-hole.net | sudo bash
post_install
