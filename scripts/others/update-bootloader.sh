#!/bin/bash
#
# Description : Update bootloader
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (22/Jun/20)
#
# Help        : https://tynick.com/blog/05-22-2020/raspberry-pi-4-boot-from-usb/
#
. ./scripts/helper.sh || . ../helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }
clear

echo -e "\nUpdate bootloader from stable branch...\n"
read -p "Press [ENTER] to Continue..."
sudo apt-get -qq update && sudo apt-get dist-upgrade
cd "$HOME"
# make a new directory and switch to it.
# this will make it easy to clean up later on
mkdir bootfiles
cd bootfiles

# download the new boot files from the raspberry pi firmware github repo
# this is kind of a backdoor way to get just those files
# otherwise this would take a very long time
wget -O - https://github.com/raspberrypi/firmware/archive/master.tar.gz | tar -xz --strip=2 "firmware-master/boot"

# copy the .elf and .dat files to your /boot directory
sudo cp *.elf /boot/
sudo cp *.dat /boot/

# change your firmware preference to stable
sudo sed -i 's/critical/stable/g' /etc/default/rpi-eeprom-update

# reboot your Pi
read -p "Now the system is going to reboot. When boot up, type in a Terminal: sudo rpi-eeprom-update. Press [ENTER] to reboot..."
sudo reboot