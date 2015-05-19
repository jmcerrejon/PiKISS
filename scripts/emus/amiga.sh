#!/bin/bash
#
# Description : Amiga emulators (uae4armiga4pi, uae4all & uae4all2)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.2 (17/Apr/15)
# Compatible  : Raspberry Pi 1 & 2 (tested) Only run on X due a SDL issue
#
clear

. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"
URL_ARMIGA="http://www.armigaproject.com/pi/uae4armiga4pi.tar.gz"
URL_UAE4ALL2="ftp://researchlab.spdns.de/rpi/uae4all/uae4all-2.5.3.4-1rpi.tgz"
URL_UAE4ALL2C="http://fdarcel.free.fr/uae4all2-rpi-chips-0_5.bz2"
KICK_FILE="http://misapuntesde.com/res/Amiga_roms.zip"
GAME="http://www.emuparadise.me/GameBase%20Amiga/Games/T/Turrican.zip"
GAME2="http://aminet.net/game/actio/AbbayeDesMorts.lha"
GAME2_DSK1="http://www.emuparadise.me/GameBase%20Amiga/Games/X/Xenon%202%20-%20Megablast_Disk1.zip"
GAME2_DSK2="http://www.emuparadise.me/GameBase%20Amiga/Games/X/Xenon%202%20-%20Megablast_Disk2.zip"

INPUT=/tmp/amigamenu.$$

trap 'rm $INPUT; exit' SIGHUP SIGINT SIGTERM

downloadKICK()
{
    wget $KICK_FILE && unzip Amiga_roms.zip && mv kick13.rom kick.rom && rm Amiga_roms.zip    
}

downloadROM()
{
    wget $1 && unzip -o *.zip && rm *.zip
}

insUAE4ARMIGA4PI()
{
    echo -e "UAE4ARMIGA4PI (Amiga emu)\n=========================\n\nMore Info: http://www.armigaproject.com/pi/pi.html\n\nInstall path: $INSTALL_DIR/uae4armiga4pi"

    if [[ $(validate_url $URL_ARMIGA) != "true" ]] ; then
        echo "Sorry, the emulator is not available here: $URL_ARMIGA. Visit the website to download it manually."
        exit
    else
        sudo apt-get install -y libsdl1.2debian libsdl-mixer1.2 libsdl-ttf2.0-0
        mkdir -p $INSTALL_DIR && cd $_
        wget -qO- -O tmp.tar.gz $URL_ARMIGA && tar xzf tmp.tar.gz && rm tmp.tar.gz
        cd uae4armiga4pi/
        downloadKICK
        cd ADFs/
        downloadROM $GAME 
        wget -O $INSTALL_DIR/uae4armiga4pi/COVERs/Turrican.adf.jpg http://files.xboxic.com/turrican2.jpg
        echo "Done!. To play you need to uncomment framebuffer display from /boot/config.txt and then, go to install path and type: ./uae4armiga4pi"
    fi
    read -p "Press [Enter] to continue..."
exit
}

insUAE4ALL2()
{
  echo -e "UAE4All2 2.5.3.4 for Raspberry Pi\n=================================\n· More Info: http://www.raspberrypi.org/forums/viewtopic.php?f=78&t=80602\n· Kickstar ROMs & Turrican included.\n· Install path: $INSTALL_DIR/uae4all\nOnly run on X Display due a SDL issue.\n\nInstalling, please wait..."

  sudo apt-get install -y libsdl1.2debian libsdl-image1.2 libsdl-ttf2.0-0 libguichan-0.8.1-1 libguichan-sdl-0.8.1-1
  SDL_fix_Rpi
  mkdir -p $INSTALL_DIR && cd $_
  wget $URL_UAE4ALL2
  tar xzf uae4all*
  rm uae4all*.tgz
  cd uae4all/kickstarts
  downloadKICK && cd ..
  downloadROM $GAME
  sudo sh -c 'echo "@pi - rtprio 90" >> /etc/security/limits.conf'
  echo -e "Done!. Type ./uae4all-rpi1 or ./uae4all-rpi2. For Full Screen: ./amiga"
  read -p "Press [Enter] to continue..."
  exit
}

insUAE4ALL2C()
{
  # Chips version
  echo -e "UAE4ALL2 : Amiga 500 & 1200 emulator with DispmanX\n==================================================\n· More Info: https://www.raspberrypi.org/forums/viewtopic.php?f=78&t=102328\n· Kickstar ROMs & Turrican included.\n· Install path: $INSTALL_DIR/uae4all\n\nInstalling, please wait..."

  sudo apt-get install -y libsdl1.2debian libsdl-image1.2 libsdl-ttf2.0-0 libguichan-0.8.1-1 libguichan-sdl-0.8.1-1
  SDL_fix_Rpi
  mkdir -p $INSTALL_DIR && cd $_
  wget $URL_UAE4ALL2C
  tar xzf uae4all*
  rm uae4all*.bz2
  cd uae4all2-rpi/
  downloadROM $GAME
  echo -e "Done!. Type ./uae4all-rpi1 or ./uae4all-rpi2. You can run 50Hz mode with the tvservice parameter."
  read -p "Press [Enter] to continue..."
  exit
}

while true
do
    dialog --clear   \
        --title     "[ Amiga emulators ]" \
        --menu      "Select emulator from the list:" 11 40 4 \
        ARMIGA      "UAE4ARMIGA4PI" \
        UAE4All2    "UAE4All2 2.5.3.4" \
        UAE4All2C   "UAE4All2 0.5 with the DispmanX (Recommended)" \
        Exit    "Exit" 2>"${INPUT}"

    menuitem=$(<"${INPUT}")

    case $menuitem in
        ARMIGA)   clear ; insUAE4ARMIGA4PI ;;
        UAE4All2) clear ; insUAE4ALL2 ;;
        UAE4All2C) clear ; insUAE4ALL2C ;;
        Exit) exit ;;
    esac
done
