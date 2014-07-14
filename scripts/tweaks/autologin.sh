#!/bin/bash
#
# Description : Autologin for Raspbian/Ubuntu
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1 (14/Jul/14)
#
#
clear

OS=$(lsb_release -si)

if [[ $OS=='Ubuntu' ]]; then
	# Add comment to 1:2345:respawn:/sbin/getty...
	sudo sed -i '/tty1/s/^/#/' /etc/init/tty1.conf

	# Insert new file on pattern position
	sudo sed -i '$i exec \/bin\/login -f '$USER' < \/dev\/tty1 > \/dev\/tty1 2>&1' /etc/init/tty1.conf
else
	# Add comment to 1:2345:respawn:/sbin/getty...
	sudo sed -i '/1:2345/s/^/#/' /etc/inittab

	# Insert new file on pattern position
	sudo sed -i 's/.*tty1.*/&\n1:2345:respawn:\/bin\/login -f '$USER' tty1 <\/dev\/tty1> \/dev\/tty1 2>\&1/' /etc/inittab
fi
read -p "Done!. Now your distro have free access and no need to login on boot!. Press [Enter] to continue..."