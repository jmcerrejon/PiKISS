#!/bin/bash
#
# Description : Install Nagios3
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.1 (12/Sep/16)
# Compatible  : Raspberry Pi 1, 2 & 3 (tested)
#
#    https://netcodger.wordpress.com/2015/03/26/nagios-3-on-a-raspberry-pi-2/
#

# Make sure this script only runs on a Raspberry Pi.
if ! uname -a | grep "raspberrypi"; then
     echo "This script only run on a Raspberry Pi."
     read -p 'Press [ENTER] to continue...'
     exit -1
fi

# Are you sure?
echo "This script is for installing Nagios 3 on a new Raspberry Pi installatoin."
echo "Installing on a modified system could overwrite any previous modifications."
read -p "Are you sure you want to continue? (y/n)" -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

sudo apt-get update

# Prompt user to set timezone as necessary.
sudo dpkg-reconfigure tzdata

# Install Nagios 3.
sudo apt install -y nagios3


# Optional install Nuvola skin.
wget "https://exchange.icinga.org/exchange/Nuvola+Style/files/145/nagios-nuvola-1.0.3.tar.gz"
mkdir nuvola
cd nuvola
tar -xzvf ../nagios-nuvola-1.0.3.tar.gz
cp -a html/* /usr/share/nagios3/htdocs/
cp -a html/stylesheets/* /etc/nagios3/stylesheets/.
cd ..
rm nagios-nuvola-1.0.3.tar.gz
rm -rf nuvola/


# Configure Nuvola
sed -i -r 's#/nagios/#/nagios3/#' /usr/share/nagios3/htdocs/config.js
mv /usr/share/nagios3/htdocs/side.html /usr/share/nagios3/htdocs/side.php

# Create the Nagiosadmin user and set a password.
htpasswd -cb /etc/nagios3/htpasswd.users nagiosadmin nagios

# Reboot and begin configuration of Nagios.
echo
echo "----------------------------------"
echo "Reboot Raspberry Pi and begin using Nagios?"
echo "See Nagios manual about configuring Nagios."
read -p "Press y to reboot and n to exit" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then
    reboot
fi
