#!/bin/bash
#
# Description : Install Lynis. Lynis is a security auditing tool for Unix and Linux based systems.
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1 (08/Sep/16)
#
clear

URL_LYNIS="http://cisofy.com/files/lynis-2.3.3.tar.gz"

validate_url(){
    if [[ `wget -S --spider $1 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then echo "true"; fi
}

if [[ $(validate_url $URL_LYNIS) != "true" ]] ; then
    read -p "Sorry, the file is not available here: $URL_LYNIS. Visit the website at https://cisofy.com/download/lynis/ to download it manually."
    exit
else
    mkdir -p $HOME/sc/ && cd $HOME/sc/
    wget $URL_LYNIS && tar -xzvf lynis*.tar.gz
    chown -R 0:0 lynis
    cd lynis
    ./lynis audit system -Q
    sudo cat /var/log/lynis-report.dat | grep "suggestion"
fi
echo -e "\nDone!. You can read the info in the file /var/log/lynis-report.dat\n"
read -p "Press [Enter] to continue..."
