#!/bin/bash
#
# Description : Personal script to make my custom Raspberry Pi OS
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.3.2 (15/Jul/20)
# Compatible  : Raspberry Pi 1-4 (tested)
#
clear

sudo apt-get update

read -p "Do you want to dist upgrade now? [y/n] " option
case "$option" in
y*) sudo apt-get dist-upgrade -y ;;
esac

echo -e "\nInstalling some packages...\n"
sudo apt-get install -y mc htop apt-file sshfs dialog cmake
sudo apt-get -y autoremove

echo -e "\nAdding useful alias...\n"
# Some useful alias
cp ./.bash_aliases "$HOME"/.bash_aliases

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

enableZRAM() {
	echo -e "\nEnabling ZRAM...\n"
	cat <<\EOF >/tmp/zram
#!/bin/bash

CORES=$(nproc --all)
modprobe zram num_devices=${CORES}
swapoff -a
SIZE=$(( ($(free | grep -e "^Mem:" | awk '{print $2}') / ${CORES}) * 1024 ))
CORE=0
while [ ${CORE} -lt ${CORES} ]; do
  echo ${SIZE} > /sys/block/zram${CORE}/disksize
  mkswap /dev/zram${CORE} > /dev/null
  swapon -p 5 /dev/zram${CORE}
  (( CORE += 1 ))
done
EOF
	chmod +x /tmp/zram
	sudo mv /tmp/zram /etc/zram
	sudo /etc/zram
	if [ "$(grep -c zram /etc/rc.local)" -eq 0 ]; then
		sudo sed -i 's_^exit 0$_/etc/zram\nexit 0_' /etc/rc.local
	fi
}

echo
read -p "Do you want to enable ZRAM? [y/n] " option
case "$option" in
	y*) enableZRAM ;;
esac

# Automatic fsck on start
#sudo sed -i 's/#FSCKFIX=no/FSCKFIX=yes/g' /etc/default/rcS && grep "FSCKFIX=yes" /etc/default/rcS | wc -l

# Other stuff
echo -e "\nRunning apt-file update...\n"
sudo apt-file update

echo -e "\nThe system is going to reboot in 5 seconds. Pray...\n"
sleep 5
telinit 6
