#!/bin/bash
#
# Description : Crispy-Doom ver. 1.3 to play doom,heretic,hexen,strife
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.8 (27/May/14)
#
clear

WAD_PATH="$HOME/games/"

doom(){
    if [[ ! -d $WAD_PATH/doom ]] ; then
        mkdir -p $WAD_PATH
        wget -P /tmp http://www.bestoldgames.net/download/bgames/doom.zip
        unzip /tmp/doom.zip -d $WAD_PATH *.WAD
        rm /tmp/doom.zip
    fi
}

heretic(){
    if [[ ! -d $WAD_PATH/Strife ]] ; then
        mkdir -p $WAD_PATH
        wget -P /tmp http://www.bestoldgames.net/download/bgames/heretic.zip
        unzip /tmp/doom.zip -d $WAD_PATH *.WAD
        rm /tmp/doom.zip
    fi

}

hexen(){
    if [[ ! -d $WAD_PATH/Strife ]] ; then
        mkdir -p $WAD_PATH
        wget -P /tmp http://www.bestoldgames.net/download/bgames/hexen.zip
        unzip /tmp/doom.zip -d $WAD_PATH *.WAD
        rm /tmp/doom.zip
    fi

}

strife(){
    if [[ ! -d $WAD_PATH/Strife ]] ; then
        mkdir -p $WAD_PATH
        wget -P /tmp http://www.bestoldgames.net/download/bgames/strife.zip
        unzip /tmp/doom.zip -d $WAD_PATH *.WAD
        rm /tmp/doom.zip
    fi
}

pack(){
    if [[ ! -d $WAD_PATH/Strife ]] ; then
        mkdir -p $WAD_PATH
        wget -P /tmp/wads.zip http://download1433.mediafire.com/imegy46e5omg/w2551ilfsx0sai7/Wads+B%C3%A1sicos.jar
        unzip /tmp/wads.zip -d $WAD_PATH *.WAD
        rm /tmp/wads.zip
    fi
}

sudo apt-get install -y libsdl1.2debian libsdl-image1.2 libsdl-mixer1.2 libsdl-net1.2 timidity

wget -P /tmp http://misapuntesde.com/res/crispy-doom_1.3_armhf.deb
sudo dpkg -i /tmp/crispy-doom_1.3_armhf.deb
rm /tmp/crispy-doom_1.3_armhf.deb

pack

read -p "Done!. Execute crispy-{doom,heretic,hexen,strife} with '-iwad path/to/wad-file.wad' parameter. Press [Enter] to continue..."