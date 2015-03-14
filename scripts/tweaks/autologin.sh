#!/bin/bash
#
# Description : Autologin
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.3 (09/Mar/15)
# Compatible  : Raspberry Pi 1 & 2 (tested), ODROID-C1 (tested)
#
clear

. ../helper.sh || . ./scripts/helper.sh ||
	{ clear && echo "ERROR : ./script/helper.sh not found." && exit 1 ;}
check_board

fn_autologin_RPi(){
	# Add comment to 1:2345:respawn:/sbin/getty...
	sudo sed -i '/1:2345/s/^/#/' /etc/inittab

	# Insert new file on pattern position
	sudo sed -i 's/.*tty1.*/&\n1:2345:respawn:\/bin\/login -f pi tty1 <\/dev\/tty1> \/dev\/tty1 2>\&1/' /etc/inittab
}

fn_autologin_ODROID(){
	sudo sed -i '/38400/s/^/#/' /etc/init/tty1.conf
	sudo sed -i 's/.*38400.*/&\nexec \/bin\/login -f '$USER' < \/dev\/tty1 > \/dev\/tty1 2>\&1/' /etc/init/tty1.conf
}

if [[ ${MODEL} == 'Raspberry Pi' ]]; then
	fn_autologin_RPi
elif [[ ${MODEL} == 'ODROID-C1' ]]; then
	fn_autologin_ODROID
fi

read -p "Done!. Warning: Now your distro have free access and no need to login on boot!. Press [Enter] to continue..."
