#!/bin/bash
#
# Description : Personal script to make my custom Raspbian
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.3.1 (26/Jun/20)
# Compatible  : Raspberry Pi 1-4 (tested)
#
# Best method to get, SSH into RPi and: wget -O pre.sh https://goo.gl/qQ3JDv && chmod +x pre.sh && ./pre.sh
#
clear

sudo apt-get update

read -p "Do you want to dist upgrade now? [y/n] " option
case "$option" in
	y*) sudo apt-get dist-upgrade -y ;;
esac

echo -e "\nInstalling some packages...\n"
sudo apt-get install -y mc htop apt-file sshfs dialog
sudo apt-get -y autoremove

echo -e "\nAdding useful alias...\n"
# Some useful alias
cp ./.bash_aliases $HOME/.bash_aliases

disableSwap() {
	# Disable partition "swap"
	sudo dphys-swapfile swapoff
	sudo dphys-swapfile uninstall
	sudo update-rc.d dphys-swapfile remove
}

read -p "Do you want to disable SWAP? [y/n] " option
case "$option" in
	y*) disableSwap ;;
esac

# Automatic fsck on start
#sudo sed -i 's/#FSCKFIX=no/FSCKFIX=yes/g' /etc/default/rcS && grep "FSCKFIX=yes" /etc/default/rcS | wc -l

# Other stuff
sudo apt-file update

# Sometime rpi-update broke my Raspbian, so be carefull
sudo rpi-update

echo -e "\nThe system is going to reboot in 5 seconds, pray...\n"
sleep 5
sudo reboot