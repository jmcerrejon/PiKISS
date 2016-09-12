#!/bin/bash
#
# Description : Net Tools - MITM Pentesting Opensource Toolkit
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.3 (5/Apr/15)
#
# Help        · http://www.jsitech.com/seguridad/net-tools-mitm-pentesting-opensource-toolkit/
clear

. ./scripts/helper.sh || . ../helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

echo -e "\nNet Tools - MITM Pentesting Opensource Toolkit\n==============================================\n\n· Require run from X\n\n"

check_update

echo -e "\nInstalling dependences (62.3 MB)...\n\n"
sudo apt-get install -y zenity nmap ettercap-text-only macchanger driftnet apache2 sslstrip

echo -e "\nInstalling MetaSploit (latest)...\n\n"
mkdir -p $HOME/sc && cd $HOME/sc
wget http://downloads.metasploit.com/data/releases/framework-latest.tar.bz2
tar jxpf framework-latest.tar.bz2
sudo apt-get install -y ruby subversion
sudo gem install bundler
sudo gem install bcrypt
cd msf3
./msfconsole
cd ..

# Net Tools
wget -O opensource.tar.gz http://sourceforge.net/projects/netoolsh/files/latest/download?source=files
tar -xzvf opensource.tar.gz
cd opensource
./nettool.sh
read -p "Done!. to use the app, cd $HOME/sc/opensource and run ./netool.sh. Press [ENTER] to Continue..."
