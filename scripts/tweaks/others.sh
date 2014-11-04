#!/bin/bash
#
# Description : Other tweaks yes/no answer
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.3 (4/Nov/14)
#
# Help        · http://www.ideaheap.com/2013/07/stopping-sd-card-corruption-on-a-raspberry-pi/
#
clear

SDLess(){
	#
	# Set up tmpfs mounts for worst offenders. Do other tweaks
	#
	sudo sh -c 'echo "proc            /proc               proc    defaults          0   0\n/dev/mmcblk0p1  /boot               vfat    ro,noatime        0   2\n/dev/mmcblk0p2  /                   ext4    defaults,noatime  0   1\nnone            /var/run        tmpfs   size=1M,noatime       0   0
\nnone            /var/log        tmpfs   size=1M,noatime       0   0" > /etc/fstab'

	#
	# Disable swapping
	#
	sudo dphys-swapfile swapoff && sudo dphys-swapfile uninstall && sudo update-rc.d dphys-swapfile remove


}

echo -e "Tweaks recopilation\n======\n"

echo -e "\nEthernet Network Adapter."
read -p "Disable (y/n)?" option
case "$option" in
    y*) echo -n "1-1.1:1.0" | sudo tee /sys/bus/usb/drivers/smsc95xx/unbind ;;
esac

echo -e "\nCPU scaling governor to performance."
read -p "Disable (y/n)?" option
case "$option" in
    y*) echo -n performance | sudo tee /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ;;
esac

echo -e "\nLess SD card writes to stop corruptions."
read -p "Agree (y/n)?" option
case "$option" in
    y*) SDLess ;;
esac

read -p "Have a nice day and don't blame me!. Press [Enter] to continue..."