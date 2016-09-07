#!/bin/bash
#
# Description : Return to Castle Wolfenstein for Raspberry Pi
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9 (07/Sep/16)
# Compatible  : Raspberry Pi 1, 2 & 3 (tested)
# TIP         : You need at least 160 GB assigned to GPU
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"
URL_FILE="https://github.com/hexameron/RaspberryPiRecipes/archive/master.zip"
PAK_FILE_SHARE="ftp://ftp.gr.freebsd.org/pub/vendors/idgames/idstuff/wolf/linux/wolfspdemo-linux-1.1b.x86.run"
PAK_FILE_FULL="https://www.dropbox.com/s/wugt32x7arkjff4/wolfc.zip?dl=0"
LICENSE="Complete"

install(){
    mkdir -p $INSTALL_DIR && cd $_
    wget -qO- -O tmp.zip $URL_FILE && unzip -qq -o tmp.zip  && rm tmp.zip
    mv $INSTALL_DIR/RaspberryPiRecipes-master/ $INSTALL_DIR/RWolfenstein

    if [[ $LICENSE == 'Shareware' ]]; then
        wget -O $HOME/wolf.run $PAK_FILE_SHARE
        cd $HOME
        tail -n +175 wolf.run | tar -xz demomain/pak0.pk3
        if [ $(uname -m) == 'armv7l' ]; then
            mv demomain/pak0.pk3 $INSTALL_DIR/RWolfenstein/armv7/RTCW/pak0.pk3
        else
            mv demomain/pak0.pk3 $INSTALL_DIR/RWolfenstein/armv6/RTCW/pak0.pk3
        fi

        rm -r wolf.run demomain
    else
        wget -4 -O /tmp/pak_files.zip $PAK_FILE_FULL
        if [ $(uname -m) == 'armv7l' ]; then
            unzip -qq -o /tmp/pak_files.zip -d $INSTALL_DIR/RWolfenstein/armv7/RTCW
        else
            unzip -qq -o /tmp/pak_files.zip -d $INSTALL_DIR/RWolfenstein/armv6/RTCW
        fi
    fi

    echo -e "\nModifying GPU=160 on /boot/config.txt"
    sudo mount -o remount,rw /boot
    $(grep -q gpu_mem "/boot/config.txt") && sudo sed -i 's/gpu_mem.*/gpu_mem=160/g' /boot/config.txt || sudo sed -i '$i gpu_mem=160' /boot/config.txt
    sudo cp /boot/config.txt{,.bak} && sudo sh -c 'echo "gpu_mem=160" >> /boot/config.txt'
    if [ $(uname -m) == 'armv7l' ]; then
        echo -e "\nDone!.\n\n· I changed the GPU memory to 160, please reboot. To play go to $INSTALL_DIR/RWolfenstein/armv7/RTCW and type: ./wolfsp.exe\n· If you get a black screen on Terminal, try to run on desktop environment.\n\nEnjoy!\n"
    else
        echo -e "\nDone!.\n\n· I changed the GPU memory to 160, please reboot. To play go to $INSTALL_DIR/RWolfenstein/armv6/RTCW and type: ./wolfsp.arm\n· If you get a black screen on Terminal, try to run on desktop environment.\n\nEnjoy!\n"
    fi

    read -p "Press [Enter] to continue..."
    exit
}

dialog --title     "[ Return to Castle Wolfenstein. PAK License ]" \
         --yes-label "Shareware (112MB)" \
         --no-label  "Complete (646MB)" \
         --yesno     "Choose what type of PAK files do you want to install. NOTE: For complete version, you must be the owner of the original game (in some countries)" 7 55

    retval=$?

    case $retval in
    0)   LICENSE="Shareware" ;;
    255) exit ;;
    esac

clear
echo -e "Return to Castle Wolfenstein. LICENSE: $LICENSE \n================================================\n\nMore Info: http://www.raspberrypi.org/forums/viewtopic.php?f=78&t=14975\n\nInstall path: $INSTALL_DIR/RWolfenstein\n\nInstalling, please wait...\n"
install
