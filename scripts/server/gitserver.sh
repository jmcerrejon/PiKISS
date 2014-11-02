#!/bin/bash
#
# Description : Git Server
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.1 (2/Nov/14)
#
# HELP        · http://www.instructables.com/id/GitPi-A-Private-Git-Server-on-Raspberry-Pi/all/?lang=es
#
clear
IP=$(hostname -I)
read -p "This make a Git Server on $HOME/gitserver. Press [ENTER] to continue or [CTRL]+C to Quit."
clear
dialog --inputbox "Enter your repo name:" 8 40 2>"${tempfile}"

echo $(<"${tempfile}")

#sudo apt-get install -y wget git-core

#mkdir -p $HOME/gitserver.git && cd $_
#git init --bare

echo -e "Now execute on your local git repository: git remote add pi pi@$IP:$HOME/gitserver.git"