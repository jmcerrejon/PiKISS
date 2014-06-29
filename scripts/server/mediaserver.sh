#!/bin/bash
#
# Description : UPnP/DLNA MediaServer
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9 (28/Jun/14)
#
# HELP        · http://www.raspberrypi.org/forums/viewtopic.php?p=518676#p518676
#             · http://www.raspberrypi.org/forums/viewtopic.php?t=16352
#             · http://www.belinuxmyfriend.com/2012/10/servidor-dlna-con-la-raspberry-pi.html
#
clear
URL_MINIDLNA="http://sourceforge.net/projects/minidlna/files/latest/download?source=files"
URL_MINIDLNA_MISA="http://misapuntesde.com/res/minidlna_1.1.3-1_armhf.deb"
MINIDLNA_FILE_CONF="http://misapuntesde.com/res/minidlna.conf"

INPUT=/tmp/mnu.sh.$$
trap "rm $INPUT; exit" SIGHUP SIGINT SIGTERM

create_dir(){
    mkdir -p ${HOME}/music && sudo chmod 777 ${HOME}/music
    mkdir -p ${HOME}/videos && sudo chmod 777 ${HOME}/videos
    mkdir -p ${HOME}/images && sudo chmod 777 ${HOME}/images
    echo -e "media_dir=A,"${HOME}"/music\nmedia_dir=P,"${HOME}"/images\nmedia_dir=V,"${HOME}"/videos" | sudo tee -a /etc/minidlna.conf
}

rygel(){
    # Unfinished
    echo -e "Rygel UPnP/DLNA MediaServer (install 55MB)\n==========================================\n Rygel allows a user to:\n\n* Browse and play media stored on a PC via a TV or PS3, even if the original content is in a format that the TV or PS3 cannot play.\n* Easily search and play media using a phone, TV, or PC.\n* Redirect sound output to DLNA speakers.\n"

    echo -e "deb http://rygel-project.org/raspbian wheezy/\ndeb-src http://rygel-project.org/raspbian wheezy/\ndeb http://vontaene.de/raspbian-updates/ . main" | sudo tee -a /etc/apt/sources.list

    sudo apt-get update && sudo apt-get install -y raspbian-dlna-renderer --force-yes

    cp /etc/rygel.conf ${HOME}/.config/rygel.conf
    create_dir
}

minidlna_latest(){
    clear
    # "Oh and by the way, it streams 1080p to XBoxes, Playstations, Smart TVs and other computers flawlessly..." - Ben Brooks
    echo -e "Compile & download minidlna(lastest version)\n============================================\n\n"
    # Doesn't work: apt-get build-dep minidlna
    mkdir -p $HOME/sc && cd $_
    wget -O tmp.tar.gz $URL_MINIDLNA
    tar xzf tmp.tar.gz && rm tmp.tar.gz
    cd minidlna*
    sudo apt-get install -y libexif-dev libsysfs-dev libid3tag0-dev libFLAC-dev libvorbis-dev libsqlite3-dev libavformat-dev autopoint autoconf libjpeg8-dev gettext libavformat53
    clear
    echo -e "\n\nGrab a coffee... ;)\n"
    ./autogen.sh && ./configure
    make
    make install
    sudo cp minidlna.conf /etc/
    sudo wget -P /etc/ $MINIDLNA_FILE_CONF
    echo -e "\n\nCreating folder music, videos & images...\n"
    create_dir
    #sudo update-rc.d minidlna defaults
    echo -e "Done!. Put files in your ${HOME}/{videos,images,music}.Go in the browser to http://<IP>:8200 to see statistics.\nTo run: sudo minidlnad" #To restart service: service minidlna force-reload && service minidlna restart"
}

minidlna_misa(){
    wget $URL_MINIDLNA_MISA
    sudo apt-get install -y libavformat53
    sudo dpkg -i minidlna_1.1.3-1_armhf.deb
    rm minidlna_1.1.3-1_armhf.deb
    sudo wget -P /etc/ $MINIDLNA_FILE_CONF
    create_dir
    #sudo update-rc.d minidlna defaults
    echo -e "Done!. Put files in your ${HOME}/{videos,images,music}.Go in the browser to http://<IP>:8200 to see statistics.\nTo run: sudo minidlnad" #: service minidlna force-reload && service minidlna restart"
}

while true
do
    dialog --clear --backtitle "UPnP/DLNA MiniDLNA MediaServer" \
    --title "[ MINIDLNA ]" \
    --menu "You can use the UP/DOWN arrow keys, the first letter of the choice as a hot key, or the number keys 1-3 to choose an option.\n\
    Choose the TASK:" 13 55 3 \
    latest "Compile the latest version (slow)" \
    minidlna "Install version 1.1.3 (fast)" \
    Exit "Exit to the shell" 2>"${INPUT}"
    menuitem=$(<"${INPUT}")

    case $menuitem in
        latest) minidlna_latest ;;
        minidlna) minidlna_misa ;;
        Exit) echo -e "\nThanks for visiting http://misapuntesde.com"; break ;;
    esac

done

# Cleanning the house
[ -f $INPUT ] && rm $INPUT
