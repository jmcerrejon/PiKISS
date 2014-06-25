#!/bin/bash
#
# Description : Menu settings to the raspbian-ua-netinst fork
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.1 (25/Jun/14)
#
clear

if [ $(/usr/bin/id -u) -ne 0 -a $NOROOT = 0 ]; then echo "Please run as root."; exit 1; fi

INPUT=/tmp/mnu.sh.$$
trap "rm $INPUT; exit" SIGHUP SIGINT SIGTERM

root_pswd(){
    clear
    passwd
    read -p 'Done!. Press [ENTER] to back to the menu...'
}

time_zone(){
    clear
    dpkg-reconfigure locales
    dpkg-reconfigure tzdata
    read -p 'Done!. Press [ENTER] to back to the menu...'
}

essential(){
    PKGS="raspi-copies-and-fills build-essentials mc alsa-base"
    clear
    echo -e "This option install the next packages: $PKGS"
    read -p "Agreed? [y/n]" option
    case "$option" in
        y*) apt-get install -y $PKGS ;;
    esac
    read -p 'Done!. Press [ENTER] to back to the menu...'
}

new_user(){
    GROUP="sudo,audio"
    clear
    dialog --inputbox "Enter user name: " 8 40 2>USER
    adduser $USER
    usermod -a -G $GROUP $USER
    id $USER
    read -p 'Done!. Press [ENTER] to back to the menu...'
}

while true
do
    dialog --clear --backtitle "Raspbian-ua-netinst Configuration Menu" \
    --title "[ M A I N - M E N U ]" \
    --menu "You can use the UP/DOWN arrow keys, the first \n\
    letter of the choice as a hot key, or the \n\
    number keys 1-9 to choose an option.\n\
    Choose the TASK" 15 50 4 \
    Root_pswd   "Set new root password (default: raspbian)" \
    Time_zone   "Adjust time zone and locale input" \
    Essential   "Install essential packages" \
    New_user    "Add a new user" \
    Exit        "Exit to the shell" 2>"${INPUT}"
    menuitem=$(<"${INPUT}")

    case $menuitem in
        Root_pswd)  root_pswd ;;
        Time_zone)  time_zone ;;
        Essential)  essential ;;
        New_user)   new_user;;
        Exit)       echo "Thanks for visiting http://misapuntesde.com"; break ;;
    esac
 
done
 
# Cleanning the house
[ -f $INPUT ] && rm $INPUT
