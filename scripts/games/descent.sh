#!/bin/bash
#
# Description : Descent 1 & 2
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.3 (17/Mar/15)
# Compatible  : Raspberry Pi 1 & 2 (tested)
#   
# HELP 		  : To uninstall: sudo dpkg -r d1x-rebirth-data-shareware d1x-rebirth d2x-rebirth-data-demo d2x-rebirth && $(sudo rm -r /usr/share/games/d1x-rebirth/ /usr/share/games/d2x-rebirth/ ~/.d1x-rebirth ~/.d2x-rebirth)
# 			  : https://github.com/dxx-rebirth/dxx-rebirth
clear

D1X_SHARE_URL='https://www-user.tu-chemnitz.de/~heinm/dxx/deb/d1x-rebirth-data-shareware_1.4-1_all.deb'
D2X_SHARE_URL='https://www-user.tu-chemnitz.de/~heinm/dxx/deb/d2x-rebirth-data-demo_1.0-1_all.deb'
D1X_URL='https://www-user.tu-chemnitz.de/~heinm/dxx/deb/d1x-rebirth_0.58.1-1_armhf.deb'
D2X_URL='https://www-user.tu-chemnitz.de/~heinm/dxx/deb/d2x-rebirth_0.58.1-1_armhf.deb'
D1X_HIGH_TEXTURE_URL='http://www.dxx-rebirth.com/download/dxx/res/d1xr-hires.dxa'
D1X_OGG_URL='http://www.dxx-rebirth.com/download/dxx/res/d1xr-sc55-music.dxa'
D2X_OGG_URL='http://www.dxx-rebirth.com/download/dxx/res/d2xr-sc55-music.dxa'
GAME_DIR='/usr/share/games'

if  which /usr/games/d1x-rebirth >/dev/null ; then
    read -p "Warning!: D1X Rebirth already installed. Press [ENTER] to continue..."
fi

if  which /usr/games/d2x-rebirth >/dev/null ; then
    read -p "Warning!: D2X Rebirth already installed. Press [ENTER] to continue..."
fi

D1X_RPI(){
	clear && echo -e "\nInstalling Descent 1 for Raspberry Pi\n=====================================\n\n· Please wait...\n"
	wget -P /temp $D1X_SHARE_URL $D1X_URL
	sudo apt-get install -y libphysfs1
	sudo dpkg -i /temp/d1x-rebirth_0.58.1-1_armhf.deb /temp/d1x-rebirth-data-shareware_1.4-1_all.deb
	rm /temp/d1x-rebirth_0.58.1-1_armhf.deb /temp/d1x-rebirth-data-shareware_1.4-1_all.deb
	clear && echo -e "\nInstalling HIGH textures quality...\n\nPlease wait...\n" && sudo wget -P $GAME_DIR/d1x-rebirth $D1X_HIGH_TEXTURE_URL
	echo -e "\n\nInstalling OGG Music for better experience...\n\n· All music was recorded with the Roland Sound Canvas SC-55 MIDI Module.\n\nPlease wait...\n" && sudo wget -P $GAME_DIR/d1x-rebirth $D1X_OGG_URL
}

D2X_RPI(){
	clear && echo -e "\nInstalling Descent 2 for Raspberry Pi\n=====================================\n\nPlease wait...\n"
	wget -P /temp $D2X_SHARE_URL $D2X_URL
	sudo apt-get install -y libphysfs1
	sudo dpkg -i /temp/d2x-rebirth_0.58.1-1_armhf.deb /temp/d2x-rebirth-data-demo_1.0-1_all.deb
	rm /temp/d2x-rebirth_0.58.1-1_armhf.deb /temp/d2x-rebirth-data-demo_1.0-1_all.deb
	clear && echo -e "\nInstalling OGG Music for better experience...\n\n· All music was recorded with the Roland Sound Canvas SC-55 MIDI Module.\n\nPlease wait...\n" && sudo wget -P $GAME_DIR/d2x-rebirth $D2X_OGG_URL
}

cmd=(dialog --separate-output --title "[ Descent 1 & 2 Shareware ]" --checklist "Move with the arrows up & down. Space to select the game(s) you want to install:" 9 135 16)
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
