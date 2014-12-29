#!/bin/bash
#
# Description : Crispy-Doom ver. 1.3 to play doom,heretic,hexen,strife
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9 (24/Jun/14)
#
# TODO        · Test pack function
#
clear

WAD_PATH="$HOME/games/"
URL_WAD_PACK="http://download944.mediafire.com/5dsc6ck17ksg/w2551ilfsx0sai7/Wads+Básicos.jar"

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
        wget -P /tmp/ $URL_WAD_PACK
        mv /tmp/Wads+Básicos.jar /tmp/wads.zip && unzip /tmp/wads.zip -d $WAD_PATH *.WAD
        rm /tmp/wads.zip
    fi
}



if [ ! -e "/usr/local/games/crispy-doom" ];then
    sudo apt-get install -y libsdl1.2debian libsdl-image1.2 libsdl-mixer1.2 libsdl-net1.2 timidity

    wget -P /tmp http://misapuntesde.com/res/crispy-doom_1.3_armhf.deb
    sudo dpkg -i /tmp/crispy-doom_1.3_armhf.deb
    rm /tmp/crispy-doom_1.3_armhf.deb
    pack
else
    read -p "Crispy-Doom already installed. Installation aborted. Have a nice day! :)"
    exit
fi

read -p "Execute crispy-{doom,heretic,hexen,strife} with '-iwad path/to/wad-file.wad' parameter. Press [Enter] to continue..."