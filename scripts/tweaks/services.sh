#!/bin/bash
#
# Description : Enable/Disable services with yes/no answer
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.3 (14/May/14)
#
clear

echo -e "Enable/Disable daemons\n=======================\n"
free -h
echo -e "\nNTP (Network Time Protocol) daemon.\nTIP: Don't disable if you need time syncronization with internet."
read -p "Disable (y/n)?" option
case "$option" in
    y*) sudo service ntp stop ;;
esac

echo -e "\nTriggerhappy daemon\nTIP: Useless if your don't use keyboard keys like up/down volume, media keys..."
read -p "Disable (y/n)?" option
case "$option" in
    y*) sudo service triggerhappy stop ;;
esac

echo -e "\nAbout Desktop daemons\nDisable DBUS,Console Kit daemon,polkitd, gnome virtual filesystem\nTIP: Disable if you don't use desktop environment."
read -p "Disable (y/n)?" option
case "$option" in
    y*) sudo service dbus stop ; sudo service dbus stop ; killall console-kit-daemon ; sudo killall polkitd ; sudo killall gvfsd ; sudo killall dbus-daemon ; sudo killall dbus-launch ;;
esac

free -h
read -p "Have a nice day and don't blame me!. Press [Enter] to continue..."