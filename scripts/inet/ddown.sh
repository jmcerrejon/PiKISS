#!/bin/bash
#
# Description : Install Plowshare4 for direct download links
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.8 (5/Apr/15)
#
# TODO        · Option to select all/current user 
#
clear

echo "Plowshare4\n==========\n\n· Plowshare is a set of command-line tools (written entirely in Bash shell script) designed for managing file-sharing websites (aka Hosters).\n· More info: https://github.com/mcrapet/plowshare\n\nInstalling, please wait..."
if [[ ! -f /usr/bin/git ]]; then
    sudo apt-get install -y git
fi

cd $HOME
git clone https://github.com/mcrapet/plowshare.git
cd plowshare
sudo make install
cd ..
rm -rf $HOME/plowshare
read -p 'Done!. You can use plowdel, plowdown, plowlist, plowmod, plowprobe, plowup. Press [ENTER] to continue...'
