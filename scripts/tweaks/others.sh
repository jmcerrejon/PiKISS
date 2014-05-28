#!/bin/bash
#
# Description : Other tweaks yes/no answer
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.2 (14/May/14)
#
# Help        · http://www.raspberrypi.org/forums/viewtopic.php?f=66&t=61033
#
clear

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

read -p "Have a nice day and don't blame me!. Press [Enter] to continue..."