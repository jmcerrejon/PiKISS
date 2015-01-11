#!/bin/bash
#
# Description : Install Lynis. Lynis is a security auditing tool for Unix and Linux based systems. 
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (11/Jan/15)
#
clear

URL_LYNIS="https://cisofy.com/files/lynis-1.6.4.tar.gz"

echo -e "Installing Lynis... \n\nIt is a security auditing tool for Unix and Linux based systems.\nFor more info, please visit: https://cisofy.com/lynis/\n"

mkdir -p $HOME/sc/
wget $URL_LYNIS && sudo tar -xzvf lynis*.tar.gz && rm lynis*.tar.gz
cd lynis
sudo ./lynis -c -Q
sudo cat /var/log/lynis-report.dat | grep "suggestion"
read -p "Press [ENTER] to continue..."