#!/bin/bash
#
# Description : Remove packages
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.3 (31/Oct/14)
#
# Help:       · http://www.cnx-software.com/2012/07/31/84-mb-minimal-raspbian-armhf-image-for-raspberry-pi/
#             · https://extremeshok.com/1081/raspberry-pi-raspbian-tuning-optimising-optimizing-for-reduced-memory-usage/
#
clear

df -h
echo -e "Remove packages\n===============\n"

read -p "I'm hungry. Can I delete sonic-pi (39 MB space will be freed)? (y/n) " option
case "$option" in
    y*) sudo apt-get remove -y sonic-pi;;
esac

# Maybe another method. This is so destructive!
read -p "Mmm!, Desktop environment (Warning, this is so destructive!)? (y/n) " option
case "$option" in
    y*) sudo apt-get remove -y --purge libx11-.* ; sudo apt-get remove -y `sudo dpkg --get-selections | grep -v "deinstall" | grep x11 | sed s/install//` ;;
esac

read -p "Remove packages for developers (OK if you're not one)? (y/n) " option
case "$option" in
    y*) sudo apt-get remove -y `sudo dpkg --get-selections | grep "\-dev" | sed s/install//` ;;
esac

read -p "I hate Python. Can I remove it? (y/n) " option
case "$option" in
    y*) sudo apt-get remove -y `sudo dpkg --get-selections | grep -v "deinstall" | grep python | sed s/install//` ;;
esac

read -p "Python games? Please, say yes! (y/n) " option
case "$option" in
    y*) rm -rf python_games ;;
esac

# alsa?, wavs, ogg?
read -p "Delete all related with sound? (audio support) (y/n) " option
case "$option" in
    y*) sudo apt-get remove -y `sudo dpkg --get-selections | grep -v "deinstall" | grep sound | sed s/install//` ;;
esac

read -p "Delete all related with wolfram engine (463 MB space will be freed)? (y/n) " option
case "$option" in
    y*) sudo apt-get remove -y wolfram-engine ;;
esac
#sudo apt-get remove `sudo dpkg --get-selections | grep -v "deinstall" | grep ssh | sed s/install//`
#sudo apt-get install dropbear
sudo apt-get autoremove -y

df -h
read -p "Have a nice day and don't blame me!. Press [Enter] to continue..."
