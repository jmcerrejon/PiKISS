#!/bin/bash
#
# Description : Crispy-Doom ver. 2.3 to play doom,heretic,hexen,strife
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.3 (07/Sep/16)
# Compatible  : Raspberry Pi 1, 2 & 3 (tested), ODROID-C1 (tested)
#
# HELP        : To compile crispy-doom, remember: sudo apt-get install -y sdl-net1.2-dev sdl-mixer1.2-dev libsdl1.2-dev autoconf
# Dependencies: libsdl1.2debian,libsdl-mixer1.2,libsdl-net1.2,timidity
#
clear

. ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

WAD_PATH="$HOME/games"
URL_DOOM="https://www.dropbox.com/s/jy2q3f56qtl3tmu/dc.zip?dl=0"
URL_HERETIC="https://www.dropbox.com/s/bwnx5707ya6g05w/hc.zip?dl=0"
URL_HEXEN="https://www.dropbox.com/s/zj127jifcxdq7fa/hec.zip?dl=0"
URL_STRIFE="https://www.dropbox.com/s/nb6ofa4nlt7juv5/sc.zip?dl=0"
CRISPY_DOOM='https://www.dropbox.com/s/8kyw06q7znnfjc4/crispy-doom_2.3_armhf.deb?dl=0'
SHORTCUTS='crispy_modified_link.zip'
LICENSE="Complete"

get_wad(){
    [ ! -d  $HOME/games ] && mkdir -p $HOME/games
    wget -O $WAD_PATH/$1.zip $2
    unzip $WAD_PATH/$1.zip -d $WAD_PATH
    rm $WAD_PATH/$1.zip
}

share_version(){
    URL_DOOM="https://www.dropbox.com/s/5ms8k3mpcu64jgd/ds.zip?dl=0"
    URL_HERETIC="https://www.dropbox.com/s/gkv4ulnonoghtgl/hs.zip?dl=0"
    URL_HEXEN="https://www.dropbox.com/s/mcy16sljsw14d6d/hes.zip?dl=0"
    URL_STRIFE="https://www.dropbox.com/s/z90da1azq2uhstp/ss.zip?dl=0"
}


menu(){

    dialog --title     "[ Crispy-Doom. WADs License ]" \
         --yes-label "Shareware" \
         --no-label  "Complete" \
         --yesno     "Choose what type of WAD files do you want to install. NOTE: For complete version, you must be the owner of the original game (in some countries)" 7 55

    retval=$?

    case $retval in
    0)   share_version ; LICENSE="Shareware" ;;
    255) exit ;;
    esac

    cmd=(dialog --separate-output --title "[ Crispy-Doom. WADs License: $LICENSE ]" --checklist "Move with the arrows up & down. Space to select the game(s) you want to install" 13 120 16)
    options=(
             Doom "Space marine operating under the UAC (Union Aerospace Corporation), who fights hordes of demons" on
             Heretic "Player must first fight through the undead hordes infesting the site" off
             Hexen "It is the sequel to 1994's Heretic" off
             Strife "The game is set in a world where a dark religion called The Order has taken over" off)
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    for choice in $choices
    do
        case $choice in
            Doom)
                get_wad doom $URL_DOOM ; sudo sh -c "echo 'crispy-doom -iwad $WAD_PATH/wads/DOOM.WAD' > /usr/bin/doom" && sudo chmod +x /usr/bin/doom
                ;;
            Heretic)
                get_wad heretic $URL_HERETIC ; sudo sh -c "echo 'crispy-heretic -iwad $WAD_PATH/wads/HERETIC.WAD' > /usr/bin/heretic" && sudo chmod +x /usr/bin/heretic
                ;;
            Hexen)
                get_wad Hexen $URL_HEXEN ; sudo sh -c "echo 'crispy-hexen -iwad $WAD_PATH/wads/HEXEN.WAD' > /usr/bin/hexen" && sudo chmod +x /usr/bin/hexen
                ;;
            Strife)
                get_wad Strife $URL_STRIFE ; sudo sh -c "echo 'crispy-strife -iwad $WAD_PATH/wads/STRIFE.WAD' > /usr/bin/strife" && sudo chmod +x /usr/bin/strife
                ;;
        esac
    done
}

if [ ! -e "/usr/local/games/crispy-doom" ];then
    sudo apt-get install -y libsdl1.2debian libsdl-mixer1.2 libsdl-net1.2 timidity

    # Check if SDL is fixed to RPi2
    SDL_fix_Rpi

    if [[ ${MODEL} == 'ODROID-C1' ]]; then
        CRISPY_DOOM='https://www.dropbox.com/s/d681t8ida2rv10z/crispy-doom-ODROID_2-3_armhf.deb?dl=0'
    fi

    wget -O $HOME/crispy-doom.deb $CRISPY_DOOM
    sudo dpkg -i $HOME/crispy-doom.deb
    rm $HOME/crispy-doom.deb
    wget -P ~/.local/share/applications http://misapuntesde.com/res/$SHORTCUTS && unzip ~/.local/share/applications/$SHORTCUTS -d ~/.local/share/applications && rm ~/.local/share/applications/$SHORTCUTS
else
    read -p "Crispy-Doom already installed. Press [ENTER] to continue..."
fi

menu

read -p "To play, just type doom, heretic, hexen(shareware version can fail) or strife(shareware version can fail), depending the game you have installed. Press [Enter] to continue..."
