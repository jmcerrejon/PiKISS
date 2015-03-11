#!/bin/bash
#
# Description : Other tweaks yes/no answer
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.7 (10/Mar/15)
#
# Help        · http://www.raspberrypi.org/forums/viewtopic.php?f=31&t=11642
#             · https://extremeshok.com/1081/raspberry-pi-raspbian-tuning-optimising-optimizing-for-reduced-memory-usage/
#
clear

. ../helper.sh || . ./scripts/helper.sh ||
    { clear && echo "ERROR : ./script/helper.sh not found." && exit 1 ;}
check_board

SDLess_Rpi(){
	sudo sh -c 'echo "proc            /proc               proc    defaults          0   0\n/dev/mmcblk0p1  /boot               vfat    ro,noatime        0   2\n/dev/mmcblk0p2  /                   ext4    defaults,noatime  0   1\nnone            /var/run        tmpfs   size=1M,noatime       0   0
\nnone            /var/log        tmpfs   size=1M,noatime       0   0" > /etc/fstab'
	sudo dphys-swapfile swapoff && sudo dphys-swapfile uninstall && sudo update-rc.d dphys-swapfile remove
}

tweaks_ODROID(){
    echo -e "\nDisable IPv6."
    read -p "Disable (y/n)? " option
    case "$option" in
        y*) sudo sh -c 'echo "net.ipv6.conf.all.disable_ipv6=1" >> /etc/sysctl.conf' && sudo sh -c 'echo "net.ipv6.conf.default.disable_ipv6=1" >> /etc/sysctl.conf' && sudo sh -c 'echo "net.ipv6.conf.lo.disable_ipv6=1" >> /etc/sysctl.conf' && sudo sysctl -p ; cat /proc/sys/net/ipv6/conf/all/disable_ipv6 ; echo -e "1 means DISABLED\n";;
    esac

    echo -e "\nSticky bit on /tmp to securely delete files only by their own propietary or root."
    read -p "Agree (y/n)? " option
    case "$option" in
        y*) sudo chmod +t /tmp ;;
    esac

    echo -e "\nEnable a 512MB swapfile permanently."
    read -p "Agree (y/n)? " option
    case "$option" in
        y*) sudo mkdir -p /var/cache/swap/ && sudo dd if=/dev/zero of=/var/cache/swap/myswap bs=1M count=512 && sudo mkswap /var/cache/swap/myswap && sudo swapon /var/cache/swap/myswap && sudo sh -c 'echo "/var/cache/swap/myswap    none    swap    sw    0   0" >> /etc/fstab' ; swapon -s 
    esac

    echo -e "\nFuse: Grant permission to odroid user (useful to run sshfs)."
    read -p "Agree (y/n)? " option
    case "$option" in
        y*) sudo gpasswd -a odroid fuse ;;
    esac
}

tweaks_RPi(){
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

    echo -e "\nCPU scaling governor to performance."
    read -p "Disable (y/n)?" option
    case "$option" in
        y*) echo -n performance | sudo tee /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ;;
    esac

    echo -e "\nLess SD card writes to stop corruptions."
    read -p "Agree (y/n)? " option
    case "$option" in
        y*) SDLess ;;
    esac

    echo -e "\nSticky bit on /tmp to securely delete files only by their own propietary or root."
    read -p "Agree (y/n)? " option
    case "$option" in
        y*) sudo chmod +t /tmp ;;
    esac

    echo -e "\nRemove the extra tty/getty’s | Save: +3.5 MB RAM"
    read -p "Agree (y/n)? " option
    case "$option" in
        y*) sudo sed -i '/[2-6]:23:respawn:\/sbin\/getty 38400 tty[2-6]/s%^%#%g' /etc/inittab ;;
    esac

    echo -e "\nReplace Bash shell with Dash shell | Save: +1 MB RAM"
    read -p "Agree (y/n)? " option
    case "$option" in
        y*) sudo dpkg-reconfigure dash ;;
    esac

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

    echo -e "\nReplace Deadline Scheduler with NOOP Scheduler (NOOP scheduler is best used with solid state devices such as flash memory)."
    read -p "Agree (y/n)? " option
    case "$option" in
        y*) sudo sed -i 's/deadline/noop/g' /boot/cmdline.txt ;;
    esac

    echo -e "\nFuse: Grant permission to pi user (useful to run sshfs)."
    read -p "Agree (y/n)? " option
    case "$option" in
        y*) sudo gpasswd -a pi fuse ;;
    esac
}

echo -e "Tweak recopilations\n===================\n"

if [[ ${MODEL} == 'Raspberry Pi' ]]; then
    tweaks_RPi
elif [[ ${MODEL} == 'ODROID-C1' ]]; then
    tweaks_ODROID
fi

read -p "Have a nice day and don't blame me!. Press [Enter] to continue..."


