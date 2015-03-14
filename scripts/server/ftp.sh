#!/bin/bash
#
# Description : Install a FTP server (vsftpd)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9 (12/Mar/15)
# Compatible  : Raspberry Pi 1 & 2 (tested), ODROID-C1 (tested)
#
# Help        · http://www.tuxmaniacs.it/2015/03/server-ftp-con-raspberry-pi.html
#			  · http://www.instructables.com/id/VSFTPD-Installation-Setup-on-Ubuntu/?ALLSTEPS
#
clear

IP=$(ifconfig eth0 | grep inet | awk '{print $2}')

if which vsftpd >/dev/null ; then
    read -p "vsftpd already installed. Aborting. Press [ENTER] to exit..." ; exit 1
fi

echo -e "vsftpd Server\n=============\n\n·Its lightweight (aprox. 329 kB) & allows it to scale very efficiently, and many large sites (ftp.redhat.com, ftp.debian.org, ftp.freebsd.org) currently utilize vsftpd as their FTP server of choice.\n\nInstallig, please wait..."

sudo apt-get -y install vsftpd

read -p "Allow anonymous FTP? [y/n] " option
case "$option" in
    n*) sudo sed -i '/anonymous_enable=YES/s/^/#/' /etc/vsftpd.conf
esac

read -p "Allow local users to log in? [y/n] " option
case "$option" in
    y*) sudo sed -i 's/^#local_enable=YES/local_enable=YES/' /etc/vsftpd.conf
esac

read -p "Enable any form of FTP write command? [y/n] " option
case "$option" in
    y*) sudo sed -i 's/^#write_enable=YES/write_enable=YES/' /etc/vsftpd.conf
esac

sudo service vsftpd restart



read -p "Done!. Use a ftp client & connect to $IP"
