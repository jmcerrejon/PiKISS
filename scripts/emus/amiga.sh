#!/bin/bash
#
# Description : Amiga emulators (uae4armiga4pi, uae4all & uae4all2)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1 (14/Aug/14)
#
clear

INSTALL_DIR="/home/$USER/games"
URL_ARMIGA="http://www.armigaproject.com/pi/uae4armiga4pi.tar.gz"
URL_UAE4ALL="ftp://researchlab.spdns.de/rpi/uae4all/uae4all-2.5.3.2rpi/uae4all-2.5.3.2rpi.tgz"
URL_UAE4ALL2="ftp://researchlab.spdns.de/rpi/uae4all2/uae4all2-2.3.5.3rpi.tgz"
KICK_FILE="http://misapuntesde.com/res/Amiga_roms.zip"
GAME="http://www.emuparadise.me/GameBase%20Amiga/Games/T/Turrican.zip"
GAME2_DSK1="http://www.emuparadise.me/GameBase%20Amiga/Games/X/Xenon%202%20-%20Megablast_Disk1.zip"
GAME2_DSK2="http://www.emuparadise.me/GameBase%20Amiga/Games/X/Xenon%202%20-%20Megablast_Disk2.zip"

INPUT=/tmp/amigamenu.$$

trap 'rm $INPUT; exit' SIGHUP SIGINT SIGTERM

validate_url(){
    if [[ `wget -S --spider $1 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then echo "true"; fi
}

changeInstallDir(){
    echo "Enter new full path:"
    read INSTALL_DIR
    echo "New path: $INSTALL_DIR"
}

downloadKICK(){
  if [[ $(validate_url $KICK_FILE) != "true" ]] ; then
    read -p "Sorry, the KICK ROM is not available. Search and download it manually. Press [ENTER] to continue..."
  else
    wget $KICK_FILE && unzip Amiga_roms.zip && mv kick13.rom kick.rom && rm Amiga_roms.zip    
  fi
}

downloadROM(){
  if [[ $(validate_url $GAME) != "true" ]] ; then
    read -p "Sorry, the game is not available. Search another one and download it to $INSTALL_DIR manually. Press [ENTER] to continue..."
  else
    wget $1 && unzip -o *.zip && rm *.zip
  fi
}

menu(){
  while true; do
      echo " "
      read -p "Is it right? [y/n] " yn
      case $yn in
      [Yy]* ) echo "Installing, please wait..." && break;;
      [Nn]* ) changeInstallDir;;
      [Ee]* ) exit;;
      * ) echo "Please answer (y)es, (n)o or (e)xit.";;
      esac
  done
}

insUAE4ARMIGA4PI(){
    echo -e "UAE4ARMIGA4PI (Amiga emu)\n=========================\n\nMore Info: http://www.armigaproject.com/pi/pi.html\n\nInstall path: $INSTALL_DIR/uae4armiga4pi"
   
    menu

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

insUAE4ALL(){
  echo -e "UAE4All for Raspberry Pi\n========================\n· More Info: http://www.raspberrypi.org/forums/viewtopic.php?f=78&t=17928\n· Kickstar ROMs & Xenon2 included.\n\nInstall path: $INSTALL_DIR"

  menu

  if [[ $(validate_url $URL_UAE4ALL) != "true" ]] ; then
      echo "Sorry, the emulator is not available here: $URL_UAE4ALL. Visit the website to download it manually."
      exit
  else
      sudo apt-get install -y libsdl1.2debian libsdl-image1.2 libsdl-ttf2.0-0 libguichan-0.8.1-1 libguichan-sdl-0.8.1-1
      mkdir -p $INSTALL_DIR && cd $_
      wget $URL_UAE4ALL
      tar xzf uae4all*
      rm -rf uae4all*.tgz
      cd uae4all/kickstarts
      downloadKICK && cd ..
      downloadROM $GAME
      sudo sh -c 'echo "@pi - rtprio 90" >> /etc/security/limits.conf'
      echo -e "Done!. Type ./uae4all and for Full Screen: ./amiga"
      read -p "Press [Enter] to continue..."
      exit
  fi
}

insUAE4ALL2(){
  echo -e "UAE4All2 2.3.5.3 for Raspberry Pi\n=================================\n· More Info: http://www.raspberrypi.org/forums/viewtopic.php?f=78&t=80602\n· Kickstar ROMs & Turrican included.\n\nInstall path: $INSTALL_DIR"
  
  menu

  if [[ $(validate_url $URL_UAE4ALL2) != "true" ]] ; then
      echo "Sorry, the emulator is not available here: $URL_UAE4ALL. Visit the website to download it manually."
      exit
  else
      sudo apt-get install -y libsdl1.2debian libsdl-image1.2 libsdl-ttf2.0-0 libguichan-0.8.1-1 libguichan-sdl-0.8.1-1
      mkdir -p $INSTALL_DIR && cd $_
      wget $URL_UAE4ALL2
      tar xzf uae4all2*
      rm -rf uae4all2*.tgz
      cd uae4all2/kickstarts
      downloadKICK && cd ..
      downloadROM $GAME
      sudo sh -c 'echo "@pi - rtprio 90" >> /etc/security/limits.conf'
      echo -e "Done!. Type ./uae4all2 and for Full Screen: ./amiga"
      read -p "Press [Enter] to continue..."
      exit
  fi
}

while true
do
    dialog --clear   \
        --title     "[ Amiga emulators ]" \
        --menu      "Select emulator from the list:" 11 40 4 \
        ARMIGA      "UAE4ARMIGA4PI" \
        UAE4All     "UAE4All 2.5.4.2" \
        UAE4All2    "UAE4All2 2.3.5.3" \
        Exit    "Exit" 2>"${INPUT}"

    menuitem=$(<"${INPUT}")

    case $menuitem in
        ARMIGA)   clear ; insUAE4ARMIGA4PI ;;
        UAE4All)  clear ; insUAE4ALL ;;
        UAE4All2) clear ; insUAE4ALL2 ;;
        Exit) exit ;;
    esac
done
