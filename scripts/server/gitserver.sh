#!/bin/bash
#
# Description : Git Server
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.2 (5/Nov/24)
# Tested on   : Raspberry Pi 5
#
# HELP        · https://www.instructables.com/id/GitPi-A-Private-Git-Server-on-Raspberry-Pi/all/?lang=es
# 			  · https://www.pihomeserver.fr/en/2015/05/05/utiliser-le-raspberry-pi-comme-serveur-git-prive/
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

IP=$(/sbin/ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}')
INPUT=/tmp/option.sh.$$
trap "rm $INPUT; exit" SIGHUP SIGINT SIGTERM

read -p "This make a Git Server on $HOME/gitserver.git/repository_name. Press [ENTER] to continue or [CTRL]+C to Quit."
clear
dialog --inputbox "Enter your repo name:" 8 40 2>"${INPUT}"

echo $(<"${INPUT}")

mkdir -p $HOME/gitserver.git/$(<"${INPUT}") && cd $_
git init --bare
clear
# On local repository: git add . && git commit -m "initial commit" && git push pi {master,main}

echo -e "Now execute on your local git repository: git remote add pi pi@$IP:$HOME/gitserver.git/$(<"${INPUT}")\nWhen you want to submit the changes: git push pi {master,main}\nNOTE:It doesn't upload the files, only the changes."
read -p 'Press [ENTER] to continue...'
