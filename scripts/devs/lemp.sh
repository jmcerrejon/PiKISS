#!/bin/bash
#
# Description : LEMP Stack
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (23/May/21)
# Compatible  : Raspberry Pi 4 (tested)
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

add_global_github_user() {
    git config --global credential.helper store
    git config --global user.name "$GITHUB_NAME"
    git config --global user.email "$GITHUB_EMAIL"
    git config --global --list
}

install() {
    install_nginx
    install_mariadb
    add_global_github_user
    install_php
}

install_script_message
echo "
LEMP Server stack
=================

· Linux.
· Nginx (pronunced Engine-X).
· MariaDB (MySQL fork).
· PHP 7 or 8 (You choose).
"
install
