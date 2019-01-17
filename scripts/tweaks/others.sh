#!/bin/bash
#
# Description : Other tweaks yes/no answer
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.3 (17/Jan/19)
# Compatible  : Raspberry Pi 1,2 & 3 all versions (tested), ODROID-C1 (tested)
#
# Help        · http://www.raspberrypi.org/forums/viewtopic.php?f=31&t=11642
#             · https://extremeshok.com/1081/raspberry-pi-raspbian-tuning-optimising-optimizing-for-reduced-memory-usage/
#             · http://www.jeffgeerling.com/blog/2016/how-overclock-microsd-card-reader-on-raspberry-pi-3
#
clear

. ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

SDLess_Rpi(){
    sudo cp /etc/fstab{,.bak}
	sudo sh -c 'echo "proc            /proc               proc    defaults          0   0\n/dev/mmcblk0p1  /boot               vfat    ro,noatime        0   2\n/dev/mmcblk0p2  /                   ext4    defaults,noatime  0   1\nnone            /var/run        tmpfs   size=1M,noatime       0   0\nnone            /var/log        tmpfs   size=1M,noatime       0   0" > /etc/fstab'
	sudo dphys-swapfile swapoff && sudo dphys-swapfile uninstall && sudo update-rc.d dphys-swapfile remove
}

tweaks_common(){
    echo -e "\nRecreate SSH Keys (recommended)"
    read -p "Agree (y/n)? " option
    case "$option" in
        y*) sudo rm /etc/ssh/ssh_host_* ; sudo dpkg-reconfigure openssh-server ; sudo service ssh restart ;;
    esac
}

tweaks_ODROID(){
    echo -e "\nInstall esential packages:htop, mc, p7zip, scrot"
    read -p "Agree (y/n)? " option
    case "$option" in
        y*) sudo apt-get install -y htop mc p7zip scrot ;;
    esac

    echo -e "\nInstall package fuck? INFO: If you fail to write a command or forget sudo, typing fuck help you to fix the problem ;)"
    read -p "Agree (y/n)? " option
    case "$option" in
        y*) sudo easy_install thefuck && sed -i '/# Alias definitions./i\alias fuck=\x27$(thefuck $(fc -ln -1))\x27' $HOME/.bashrc ;;
    esac

    echo -e "\nDisable IPv6."
    read -p "Disable (y/n)? " option
    case "$option" in
        y*) sudo cp /etc/sysctl.conf{,.bak} && sudo sh -c 'echo "net.ipv6.conf.all.disable_ipv6=1" >> /etc/sysctl.conf' && sudo sh -c 'echo "net.ipv6.conf.default.disable_ipv6=1" >> /etc/sysctl.conf' && sudo sh -c 'echo "net.ipv6.conf.lo.disable_ipv6=1" >> /etc/sysctl.conf' && sudo sysctl -p ; cat /proc/sys/net/ipv6/conf/all/disable_ipv6 ; echo -e "1 means DISABLED\n";;
    esac

    echo -e "\nEnable Meveric repositories with dozen of apps. Check http://forum.odroid.com/viewtopic.php?f=52&t=5908 for more info."
    read -p "Agree (y/n)? " option
    case "$option" in
        y*) sudo wget -P /etc/apt/sources.list.d http://oph.mdrjr.net/meveric/sources.lists/meveric-all-C1.list && sudo wget -P /etc/apt/sources.list.d http://oph.mdrjr.net/meveric/sources.lists/meveric-all-main.list && sudo wget -P /etc/apt/sources.list.d http://oph.mdrjr.net/meveric/sources.lists/meveric-all-testing.list && sudo wget -O- http://oph.mdrjr.net/meveric/meveric.asc | sudo apt-key add - && sudo apt-get update ;;
    esac

    echo -e "\nSticky bit on /tmp to securely delete files only by their own propietary or root."
    read -p "Agree (y/n)? " option
    case "$option" in
        y*) sudo chmod +t /tmp ;;
    esac

    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor | grep 'performance' > /dev/null 2>&1
    CHECK=$?

    if [ $CHECK -eq 1 ]; then
        echo -e "\nCPU scaling governor to performance."
        read -p "Disable (y/n)?" option
        case "$option" in
            y*) echo -n performance | sudo tee /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ;;
        esac
    fi

    echo -e "\nEnable a 512MB swapfile permanently."
    read -p "Agree (y/n)? " option
    case "$option" in
        y*) sudo cp /etc/fstab{,.bak} && sudo mkdir -p /var/cache/swap/ && sudo dd if=/dev/zero of=/var/cache/swap/myswap bs=1M count=512 && sudo mkswap /var/cache/swap/myswap && sudo swapon /var/cache/swap/myswap && sudo sh -c 'echo "/var/cache/swap/myswap    none    swap    sw    0   0" >> /etc/fstab' ; swapon -s
    esac

    echo -e "\nFuse: Grant permission to odroid user (useful to run sshfs)."
    read -p "Agree (y/n)? " option
    case "$option" in
        y*) sudo gpasswd -a odroid fuse ;;
    esac
}

tweaks_RPi(){
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

    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor | grep 'performance' > /dev/null 2>&1
    CHECK=$?

    if [ $CHECK -eq 1 ]; then
        echo -e "\nCPU scaling governor to performance."
        read -p "Disable (y/n)? " option
        case "$option" in
            y*) echo -n performance | sudo tee /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ;;
        esac
    fi

    if [ $(uname -m) == 'armv7l' ]; then
        echo -e "\nOverclock Raspberry Pi to 1'35 Ghz (secure)."
        read -p "Agree (y/n)? " option
        case "$option" in
            y*) sudo cp /boot/config.txt{,.bak} && sudo sh -c 'echo "arm_freq=1350\nsdram_freq=500\nover_voltage=4\ndisable_splash=1" >> /boot/config.txt' ;;
        esac
    else
        echo -e "\nOverclock Raspberry Pi to 1 Ghz (secure)."
        read -p "Agree (y/n)? " option
        case "$option" in
            y*) sudo cp /boot/config.txt{,.bak} && sudo sh -c 'echo "arm_freq=1000\nsdram_freq=500\ncore_freq=500\nover_voltage=2\ndisable_splash=1" >> /boot/config.txt' ;;
        esac
    fi

    echo -e "\nAdd pi user to sudo group and modify /etc/sudoers (SECURITY RISK!. USE AT YOUR OWN)"
    read -p "Agree (y/n)? " option
    case "$option" in
        y*) sudo usermod -aG sudo pi && echo "pi ALL=(ALL:ALL) ALL" | sudo sh -c '(EDITOR="tee -a" visudo)' && sudo visudo -c ;;
    esac

    # Seems unstable, check & test it.
    # echo -e "\nLess SD card writes to stop corruptions."
    # read -p "Agree (y/n)? " option
    # case "$option" in
    #     y*) SDLess_Rpi ;;
    # esac

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

    echo -e "\nReplace mirrordirector.raspbian.org (sometimes down) with mirror.ox.ac.uk ?"
    read -p "Agree (y/n)? " option
    case "$option" in
        y*) sudo sed -i "/mirrordirector.raspbian.org/s/^/#/" /etc/apt/sources.list; sudo sed -i "1 s|^|deb http://mirror.ox.ac.uk/sites/archive.raspbian.org/archive/raspbian stretch main contrib non-free rpi\n|" /etc/apt/sources.list ;;
    esac
}

echo -e "Tweak recopilations\n===================\n"

if [[ ${MODEL} == 'Raspberry Pi' ]]; then
    tweaks_RPi
elif [[ ${MODEL} == 'ODROID-C1' ]]; then
    tweaks_ODROID
fi

read -p "Have a nice day and don't blame me!. Press [Enter] to continue..."
