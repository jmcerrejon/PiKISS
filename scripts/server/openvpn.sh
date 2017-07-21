#!/bin/bash
#
# Description : OpenVPN
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (21/Jul/2017)
#
# HELP		  : http://www.pivpn.io/
#
clear

echo -e "Turn Raspberry Pi into a OpenVPN Server\n\nInstalling, please wait..."

curl -L https://install.pivpn.io | bash

read -p 'Done. Press [ENTER] to continue...'
