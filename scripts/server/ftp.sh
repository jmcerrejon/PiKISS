#!/bin/bash
#
# Description : Install a FTP server (vsftpd)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9.1 (12/Sep/16)
# Compatible  : Raspberry Pi 1, 2 & 3 (tested), ODROID-C1 (tested)
#
# Help        · http://www.tuxmaniacs.it/2015/03/server-ftp-con-raspberry-pi.html
#			  · http://www.instructables.com/id/VSFTPD-Installation-Setup-on-Ubuntu/?ALLSTEPS
#
clear
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

IP=$(ifconfig eth0 | grep inet | awk '{print $2}')

# if which vsftpd >/dev/null ; then
#     read -p "vsftpd already installed. Aborting. Press [ENTER] to exit..." ; exit 1
# fi

echo -e "vsftpd Server\n=============\n\n·Its lightweight (aprox. 329 kB) & allows it to scale very efficiently, and many large sites (ftp.redhat.com, ftp.debian.org, ftp.freebsd.org) currently utilize vsftpd as their FTP server of choice.\n\nInstallig, please wait..."

# sudo apt install -y vsftpd

INSTALLER_DEPS=( vsftpd )
check_dependencies $INSTALLER_DEPS

read -p "Allow anonymous FTP? [y/n] " option
case "$option" in
    n*) sudo sed -i '/anonymous_enable=YES/s/^/#/' /etc/vsftpd.conf
esac

read -p "Allow local users to log in? [y/n] " option
case "$option" in
    y*) sudo sed -i 's/^#local_enable=YES/local_enable=YES/' /etc/vsftpd.conf
esac

read -p "Enable any user the write command? [y/n] " option
case "$option" in
    y*) sudo sed -i 's/^#write_enable=YES/write_enable=YES/' /etc/vsftpd.conf
esac

sudo service vsftpd restart

echo -e "Done!. Use a ftp client & connect to $IP"
read -p 'Press [ENTER] to continue...'
