#!/bin/bash
#
# Description : Crispy-Doom ver. 1.3 to play doom,heretic,hexen,strife
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (12/Mar/15)
#
clear

WAD_PATH="$HOME/games/"
URL_ALLWAD_PACK="https://www.dropbox.com/s/t3b2zaxwozmjym3/wads.zip?dl=0"
URL_DOOM_FULL="http://www.bestoldgames.net/download/bgames/doom.zip"
URL_HERETIC_FULL="https://www.dropbox.com/s/ekph4j0uu06nbg1/Heretic.zip?dl=0"
URL_HEXEN_FULL="http://www.bestoldgames.net/download/bgames/hexen.zip"
URL_STRIFE_FULL="http://www.bestoldgames.net/download/bgames/strife.zip"

LICENSE="Complete"

get_wad(){
    if [[ ! -d $WAD_PATH/$1 ]] ; then
        mkdir -p $WAD_PATH/$1
        wget -O /tmp/$1.zip $2
        unzip /tmp/$1.zip -d $WAD_PATH/ *.WAD || unzip /tmp/$1.zip -d $WAD_PATH/ *.wad
        #rm /tmp/$1.zip
    fi
}

menu(){

    dialog --title     "[ Crispy-Doom. License ]" \
         --yes-label "Shareware" \
         --no-label  "Complete" \
         --yesno     "Choose what type of WAD files do you want to install. NOTE: For complete version, you must be the owner of the original game (in some countries)" 7 55

    retval=$?

    case $retval in
    0)   dialog --title '[ Message ]' --msgbox 'Sorry, shareware version not implemented!' 5 46 ;;
    255) exit ;;
    esac

    cmd=(dialog --separate-output --title "[ Crispy-Doom. License: $LICENSE ]" --checklist "Move with the arrows up & down. Space to select the game(s) you want to install" 13 120 16)
    options=(All "Install all WAD files" off
             Doom "Space marine operating under the UAC (Union Aerospace Corporation), who fights hordes of demons" off
             Heretic "Player must first fight through the undead hordes infesting the site" off
             Hexen "It is the sequel to 1994's Heretic" off
             Strife "The game is set in a world where a dark religion called The Order has taken over" off)
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    for choice in $choices
    do
        case $choice in
            All)
                get_wad all $URL_ALLWAD_PACK
                read -p "Execute crispy-{doom,heretic,hexen,strife} with '-iwad $HOME/games/game_name/wad-file.wad' parameter. Press [Enter] to continue..."
                exit 1
                ;;
            Doom)
                get_wad Doom $URL_DOOM_FULL
                ;;
            Heretic)
                get_wad Heretic $URL_HERETIC_FULL
                ;;
            Hexen)
                get_wad Hexen $URL_HEXEN_FULL
                ;;
            Strife)
                get_wad Strife $URL_STRIFE_FULL
                ;;
        esac
    done
}

if [ ! -e "/usr/local/games/crispy-doom" ];then
    sudo apt-get install -y libsdl1.2debian libsdl-image1.2 libsdl-mixer1.2 libsdl-net1.2 timidity

    wget -P /tmp http://misapuntesde.com/res/crispy-doom_1.3_armhf.deb
    sudo dpkg -i /tmp/crispy-doom_1.3_armhf.deb
    rm /tmp/crispy-doom_1.3_armhf.deb
else
    read -p "Crispy-Doom already installed. Press [ENTER] to continue..."
fi

menu

read -p "Execute crispy-{doom,heretic,hexen,strife} with '-iwad path/to/wad-file.wad' parameter. Press [Enter] to continue..."