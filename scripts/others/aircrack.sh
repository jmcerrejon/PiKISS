#!/bin/bash
#
# Description : Aircrack-NG / Airoscript thanks to Robbie (https://www.blogger.com/profile/08699040638337195602)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9 (22/May/14)
#
# Help        · http://raspberrypihell.blogspot.com.es/2014/01/aircrack-ng-on-raspberry-pi.html
#
clear

echo -e "Compile & Install Aircrack-NG / Airoscript\n============================================\n"

cd $HOME
wget -o https://raw.github.com/txt3rob/Aircrack-NG_RaspberryPI/master/install.sh
sudo chmod 777 install.sh
sudo ./install.sh