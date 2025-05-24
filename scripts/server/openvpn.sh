#!/bin/bash
#
# Description : OpenVPN
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.1 (7/May/2021)
#
# HELP		  : https://www.pivpn.io/
#
. ../helper.sh || . ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }
clear

echo "
PiVPN
=====

· Turn Raspberry Pi into a OpenVPN Server
· More info: https://www.pivpn.io/
"

read -p 'Press [ENTER] to continue...'

curl -L https://install.pivpn.io | bash

exit_message
