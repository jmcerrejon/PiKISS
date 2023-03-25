#!/bin/bash
#
# Description : Install Plowshare4 for direct download links
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.1 (25/Mar/22)
#
clear

echo "Plowshare4\n==========\n\n· Plowshare is a set of command-line tools (written entirely in Bash shell script) designed for managing file-sharing websites (aka Hosters).\n· More info: https://github.com/mcrapet/plowshare\n\nInstalling, please wait..."
if [[ ! -f /usr/bin/git ]]; then
    sudo apt-get install -y git
fi

cd $HOME
git clone https://github.com/mcrapet/plowshare.git
cd plowshare
make_install_compiled_app
plowmod --install
cd ..
rm -rf $HOME/plowshare
echo -e "Done!. You can use plowdel, plowdown, plowlist, plowmod, plowprobe, plowup.\n\nExample: plowdown -a 'user:password' https://ul.to/mldskbm"
read -p 'Press [ENTER] to continue...'
