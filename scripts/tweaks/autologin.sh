#!/bin/bash
#
# Description : Autologin for Raspbian
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.2 (2/Sep/14)
#
clear

# Add comment to 1:2345:respawn:/sbin/getty...
sudo sed -i '/1:2345/s/^/#/' /etc/inittab

# Insert new file on pattern position
sudo sed -i 's/.*tty1.*/&\n1:2345:respawn:\/bin\/login -f '$USER' tty1 <\/dev\/tty1> \/dev\/tty1 2>\&1/' /etc/inittab

read -p "Done!. Now your distro have free access and no need to login on boot!. Press [Enter] to continue..."