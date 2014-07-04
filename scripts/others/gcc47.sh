#!/bin/bash
#
# Description : Install GCC on Raspberry Pi
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.1 (04/Jul/14)
#
# Help        · http://www.rpiblog.com/2014/07/installing-gcc-on-raspberry-pi.html
#
clear

echo -e "Install gcc-4.7 g++-4.7 on Raspberry Pi\n=======================================\n\nPlease wait..."
sudo apt-get install gcc-4.7 g++-4.7
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.6
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.7 40 --slave /usr/bin/g++ g++ /usr/bin/g++-4.7
sudo update-alternatives --config gcc

read -p "Done!. Press [Enter] to continue..."
