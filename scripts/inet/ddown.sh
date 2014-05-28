#!/bin/bash
#
# Description : Install Plowshare4 for direct download links
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.7 (14/May/14)
#
# TODO        · Option to select all/current user 
#
clear

echo "Installing Plowshare4..."
if [[ ! -f /usr/bin/git ]]; then
    sudo apt-get install -y git
fi

git clone https://code.google.com/p/plowshare/ plowshare4
cd plowshare4
sudo make install #PREFIX=/home/$USER
rm -r plowshare4
read -p 'Done!. Press [ENTER] to continue...'
