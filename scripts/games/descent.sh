#!/bin/bash
#
# Description : Descent 1 & 2
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.1 (17/Mar/15)
# Compatible  : Raspberry Pi 1 & 2 (tested)
#   
# HELP 		  : To uninstall: sudo dpkg -r d1x-rebirth-data-shareware d1x-rebirth d2x-rebirth-data-demo d2x-rebirth
#
clear

D1X_SHARE_URL='https://www-user.tu-chemnitz.de/~heinm/dxx/deb/d1x-rebirth-data-shareware_1.4-1_all.deb'
D2X_SHARE_URL='https://www-user.tu-chemnitz.de/~heinm/dxx/deb/d2x-rebirth-data-demo_1.0-1_all.deb'
D1X_URL='https://www-user.tu-chemnitz.de/~heinm/dxx/deb/d1x-rebirth_0.58.1-1_armhf.deb'
D2X_URL='https://www-user.tu-chemnitz.de/~heinm/dxx/deb/d2x-rebirth_0.58.1-1_armhf.deb'

if  which /usr/games/d1x-rebirth >/dev/null ; then
    read -p "Warning!: D1X Rebirth already installed. Press [ENTER] to continue..."
fi

if  which /usr/games/d2x-rebirth >/dev/null ; then
    read -p "Warning!: D2X Rebirth already installed. Press [ENTER] to continue..."
fi

D1X_RPI(){
	wget -P /temp $D1X_SHARE_URL $D1X_URL
	sudo apt-get install -y libphysfs1
	sudo dpkg -i /temp/d1x-rebirth_0.58.1-1_armhf.deb /temp/d1x-rebirth-data-shareware_1.4-1_all.deb
	rm /temp/d1x-rebirth_0.58.1-1_armhf.deb /temp/d1x-rebirth-data-shareware_1.4-1_all.deb
}

D2X_RPI(){
	wget -P /temp $D2X_SHARE_URL $D2X_URL
	sudo apt-get install -y libphysfs1
	sudo dpkg -i /temp/d2x-rebirth_0.58.1-1_armhf.deb /temp/d2x-rebirth-data-demo_1.0-1_all.deb
	rm /temp/d2x-rebirth_0.58.1-1_armhf.deb /temp/d2x-rebirth-data-demo_1.0-1_all.deb
}

cmd=(dialog --separate-output --title "[ Descent 1 & 2 Shareware ]" --checklist "Move with the arrows up & down. Space to select the game(s) you want to install:" 8 135 16)
options=(
         Descent_1 "The game requires the player to navigate labyrinthine mines while fighting virus-infected robots." on
         Descent_2 "the player must complete 24 levels where different types of AI-controlled robots will try to destroy you." off)

choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

for choice in $choices
do
    case $choice in
        Descent_1)
            D1X_RPI
            ;;
        Descent_2)
            D2X_RPI
            ;;
    esac
done

clear
read -p "Done!. type d1x-rebirth or d2x-rebirth to Play. Press [ENTER] to continue..."
