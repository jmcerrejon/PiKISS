#!/bin/bash
#
# Description : Remove packages
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9 (29/Dec/14)
#
# Help:       · http://www.cnx-software.com/2012/07/31/84-mb-minimal-raspbian-armhf-image-for-raspberry-pi/
#
clear

df -h
echo -e "\nRemove packages\n===============\n"

read -p "I'm hungry. Can I delete sonic-pi (66.6 MB space will be freed)? (y/n) " option
case "$option" in
    y*) sudo apt-get remove -y sonic-pi;;
esac

# Maybe another method. This is so destructive!
read -p "Mmm!, Desktop environment (Warning, this is so destructive!)? (y/n) " option
case "$option" in
    y*) sudo apt-get remove -y --purge libx11-.* ; sudo apt-get remove -y xkb-data `sudo dpkg --get-selections | grep -v "deinstall" | grep x11 | sed s/install//` ;;
esac

read -p "Remove packages for developers (OK if you're not one)? (y/n) " option
case "$option" in
    y*) sudo apt-get remove -y `sudo dpkg --get-selections | grep "\-dev" | sed s/install//` ;;
esac

read -p "Remove Video Core source files for developers (OK if you're not one. Free 32.6 Mb)? (y/n) " option
case "$option" in
    y*) sudo rm -r /opt/vc/src ;;
esac


read -p "Remove Java(TM) SE Runtime Environment 1.8.0 (186 MB space will be freed)? (y/n) " option
case "$option" in
    y*) sudo apt-get remove -y oracle-java8-jdk ;;
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

read -p "Other unneeded packages: ca-certificates, libraspberrypi-doc, locales, manpages. (Free 52.1 MB) (y/n) " option
case "$option" in
    y*) sudo apt-get -y remove ca-certificates libraspberrypi-doc locales manpages ;;
esac

sudo apt-get autoremove -y
sudo apt-get clean

df -h
read -p "Have a nice day and don't blame me!. Press [Enter] to continue..."
