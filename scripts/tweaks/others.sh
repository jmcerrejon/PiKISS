#!/bin/bash
#
# Description : Other tweaks yes/no answer
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.4.5 (06/Mar/22)
# Compatible  : Raspberry Pi 1-4 (tested)
#
# Help        · https://www.raspberrypi.org/forums/viewtopic.php?f=31&t=11642
#             · https://extremeshok.com/1081/raspberry-pi-raspbian-tuning-optimising-optimizing-for-reduced-memory-usage/
#             · https://www.jeffgeerling.com/blog/2016/how-overclock-microsd-card-reader-on-raspberry-pi-3
#
clear

. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

remove_swap() {
    echo -e "Removing Swap..."
    sudo dphys-swapfile swapoff
    sudo dphys-swapfile uninstall
    sudo update-rc.d dphys-swapfile remove
    sudo rm -f /var/swap
    if [[ -e /var/swap ]]; then
        echo "Something is wrong. Aborting..."
        return 1
    fi
    echo -e "Done!"
}

enable_trim() {
    echo "
Enable TRIM mode on SSD
=======================

· This script is in a very early stage (Alpha), so run it at your risk.
· Run this script attaching only ONE SSD device.
"
    read -p "Are you sure? (Y/n) " response
    if [[ $response =~ [Nn] ]]; then
        commands here
    fi
    local has_trim_enabled
    local MAX_LBA_COUNT
    local UNMAP_LBPU

    sudo apt install -y sg3-utils

    MAX_LBA_COUNT=$(sudo sg_vpd -p bl /dev/sda | grep 'Maximum unmap LBA count' | awk '{print $5}')
    UNMAP_LBPU=$(sudo sg_vpd -p lbpv /dev/sda | grep 'Unmap command supported (LBPU)' | awk '{print $5}')

    if [[ MAX_LBA_COUNT -eq 0 || UNMAP_LBPU -eq 0 ]]; then
        echo "Sorry, you can't enable TRIM. Reason: Maximum unmap LBA count or LBPU = 0"
        exit_message
    fi
}

overclock() {
    RPI_NUMBER=$(get_raspberry_pi_model_number)
    echo

    case ${RPI_NUMBER} in

    1)
        echo -e "\nOverclock Raspberry Pi ${RPI_NUMBER} to 1 Ghz (secure)."
        read -p "Agree (y/n)? " option
        case "$option" in
        y*) sudo cp /boot/config.txt{,.bak} && sudo sh -c 'echo "\narm_freq=1000\nsdram_freq=500\ncore_freq=500\nover_voltage=2\ndisable_splash=1" >> /boot/config.txt' ;;
        esac
        ;;

    2)
        echo -e "\nOverclock Raspberry Pi ${RPI_NUMBER} to 1'35 Ghz (secure)."
        read -p "Agree (y/n)? " option
        case "$option" in
        y*) sudo cp /boot/config.txt{,.bak} && sudo sh -c 'echo "\narm_freq=1350\nsdram_freq=500\nover_voltage=4\ndisable_splash=1" >> /boot/config.txt' ;;
        esac
        ;;

    3)
        echo -e "\nOverclock Raspberry Pi ${RPI_NUMBER} to 1'35 Ghz (secure)."
        read -p "Agree (y/n)? " option
        case "$option" in
        y*) sudo cp /boot/config.txt{,.bak} && sudo sh -c 'echo "\narm_freq=1350\nsdram_freq=500\nover_voltage=4\ndisable_splash=1" >> /boot/config.txt' ;;
        esac
        ;;

    4)
        echo -e "\nOverclock Raspberry Pi ${RPI_NUMBER} to 2 Ghz (get a fan)."
        read -p "Agree (y/n)? " option
        case "$option" in
        y*) sudo cp /boot/config.txt{,.bak} && sudo sh -c 'echo "\narm_freq=2000\ngpu_freq=750\nover_voltage=6\ndisable_splash=1" >> /boot/config.txt' ;;
        esac
        ;;

    *)
        return 0
        ;;
    esac
}

sudo mount -o remount,rw /boot

echo -e "\nEthernet Network Adapter."
read -p "Disable (y/n)? " option
case "$option" in
y*) echo -n "1-1.1:1.0" | sudo tee /sys/bus/usb/drivers/smsc95xx/unbind ;;
esac

echo -e "\nDisable IPv6."
read -p "Disable (y/n)? " option
case "$option" in
y*) sudo sh -c 'echo "net.ipv6.conf.all.disable_ipv6=1" > /etc/sysctl.d/disableipv6.conf' && sudo sh -c 'echo 'blacklist ipv6' >> /etc/modprobe.d/blacklist' && sudo sed -i '/::/s%^%#%g' /etc/hosts ;;
esac

cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor | grep 'performance' >/dev/null 2>&1
CHECK=$?
if [ $CHECK -eq 1 ]; then
    echo -e "\nCPU scaling governor to performance."
    read -p "Disable (y/n)? " option
    case "$option" in
    y*) echo -n performance | sudo tee /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ;;
    esac
fi

overclock

echo -e "\nAdd pi user to sudo group and modify /etc/sudoers (SECURITY RISK!. USE AT YOUR OWN)"
read -p "Agree (y/n)? " option
case "$option" in
y*) sudo usermod -aG sudo pi && echo "pi ALL=(ALL:ALL) ALL" | sudo sh -c '(EDITOR="tee -a" visudo)' && sudo visudo -c ;;
esac

echo -e "\nRecreate SSH Keys (recommended)"
read -p "Agree (y/n)? " option
case "$option" in
y*)
    sudo rm /etc/ssh/ssh_host_*
    sudo dpkg-reconfigure openssh-server
    sudo service ssh restart
    ;;
esac

echo -e "\nDelete old SSH Keys and recreate them."
read -p "Agree (y/n)? " option
case "$option" in
y*) sudo rm /etc/ssh/ssh_host_* && sudo dpkg-reconfigure openssh-server && sudo service ssh restart ;;
esac

echo -e "\nSticky bit on /tmp to securely delete files only by their own propietary or root."
read -p "Agree (y/n)? " option
case "$option" in
y*) sudo chmod +t /tmp ;;
esac

if [ -f /etc/inittab ]; then
    echo -e "\nRemove the extra tty/getty | Save: +3.5 MB RAM"
    read -p "Agree (y/n)? " option
    case "$option" in
    y*) sudo sed -i '/[2-6]:23:respawn:\/sbin\/getty 38400 tty[2-6]/s%^%#%g' /etc/inittab ;;
    esac
fi

echo -e "\nReplace Bash shell with Dash shell | Save: +1 MB RAM"
read -p "Agree (y/n)? " option
case "$option" in
y*) sudo dpkg-reconfigure dash ;;
esac

if [[ -e /var/swap ]]; then
    echo -e "\nRemove swapfile"
    read -p "Agree (y/n)? " option
    case "$option" in
    y*) remove_swap ;;
    esac
fi

echo -e "\nEnable a 512MB swapfile"
read -p "Agree (y/n)? " option
case "$option" in
y*) sudo sh -c 'sudo echo "CONF_SWAPSIZE=512" > /etc/dphys-swapfile' && sudo dphys-swapfile setup && sudo dphys-swapfile swapon ;;
esac

echo -e "\nOptimize /mount with defaults,noatime,nodiratime"
read -p "Agree (y/n)? " option
case "$option" in
y*) sudo sed -i 's/defaults,noatime/defaults,noatime,nodiratime/g' /etc/fstab ;;
esac

echo -e "\nReduce shutdown timeout for a stop job running to 5 seconds."
read -p "Agree (y/n)? " option
case "$option" in
y*) sudo sed -i 's/#DefaultTimeoutStopSec=90s/DefaultTimeoutStopSec=5s/g' /etc/systemd/system.conf ;;
esac

echo
read -p "Have a nice day and don't blame me!. Press [Enter] to continue..."
