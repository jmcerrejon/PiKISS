#!/bin/bash
#
# Description : Other tweaks yes/no answer
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.4.1 (05/Jul/20)
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

SDLess_Rpi() {
    sudo cp /etc/fstab{,.bak}
	sudo sh -c 'echo "proc            /proc               proc    defaults          0   0\n/dev/mmcblk0p1  /boot               vfat    ro,noatime        0   2\n/dev/mmcblk0p2  /                   ext4    defaults,noatime  0   1\nnone            /var/run        tmpfs   size=1M,noatime       0   0\nnone            /var/log        tmpfs   size=1M,noatime       0   0" > /etc/fstab'
	sudo dphys-swapfile swapoff && sudo dphys-swapfile uninstall && sudo update-rc.d dphys-swapfile remove
}

overclock() {
	RPI_NUMBER=$(getRaspberryPiNumberModel)
	case ${RPI_NUMBER} in

		1)
			echo -e "\nOverclock Raspberry Pi ${RPI_NUMBER} to 1 Ghz (secure)."
			read -p "Agree (y/n)? " option
			case "$option" in
				y*) sudo cp /boot/config.txt{,.bak} && sudo sh -c 'echo "arm_freq=1000\nsdram_freq=500\ncore_freq=500\nover_voltage=2\ndisable_splash=1" >> /boot/config.txt' ;;
			esac
		;;

		2)
			echo -e "\nOverclock Raspberry Pi ${RPI_NUMBER} to 1'35 Ghz (secure)."
			read -p "Agree (y/n)? " option
			case "$option" in
				y*) sudo cp /boot/config.txt{,.bak} && sudo sh -c 'echo "arm_freq=1350\nsdram_freq=500\nover_voltage=4\ndisable_splash=1" >> /boot/config.txt' ;;
			esac
			;;

		3)
			echo -e "\nOverclock Raspberry Pi ${RPI_NUMBER} to 1'35 Ghz (secure)."
			read -p "Agree (y/n)? " option
			case "$option" in
				y*) sudo cp /boot/config.txt{,.bak} && sudo sh -c 'echo "arm_freq=1350\nsdram_freq=500\nover_voltage=4\ndisable_splash=1" >> /boot/config.txt' ;;
			esac
			;;

		4)
			echo -e "\nOverclock Raspberry Pi ${RPI_NUMBER} to 2 Ghz (secure)."
			read -p "Agree (y/n)? " option
			case "$option" in
				y*) sudo cp /boot/config.txt{,.bak} && sudo sh -c 'echo "arm_freq=2000\gpu_freq=750\nover_voltage=6\ndisable_splash=1" >> /boot/config.txt' ;;
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

cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor | grep 'performance' > /dev/null 2>&1
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
	y*) sudo rm /etc/ssh/ssh_host_* ; sudo dpkg-reconfigure openssh-server ; sudo service ssh restart ;;
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
	y*) sudo sed -i "/mirrordirector.raspbian.org/s/^/#/" /etc/apt/sources.list; sudo sed -i "1 s|^|deb https://mirror.ox.ac.uk/sites/archive.raspbian.org/archive/raspbian stretch main contrib non-free rpi\n|" /etc/apt/sources.list ;;
esac

read -p "Have a nice day and don't blame me!. Press [Enter] to continue..."
