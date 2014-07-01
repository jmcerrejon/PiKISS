#!/bin/bash
#
# Description : uae4all2 Amiga emulator thanks to rSI
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9 (1/Jul/14)
#
clear

INSTALL_DIR="/home/$USER/games/"
URL_FILE="ftp://researchlab.spdns.de/rpi/uae4all2/uae4all2-2.3.5.3rpi.tgz"
KICK_FILE="http://misapuntesde.com/res/Amiga_roms.zip"

validate_url(){
    if [[ `wget -S --spider $1 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then echo "true"; fi
}

changeInstallDir(){
    echo "Enter new full path:"
    read INSTALL_DIR
    echo "New path: $INSTALL_DIR"
}

install(){
  if [[ $(validate_url $URL_FILE) != "true" ]] ; then
      echo "Sorry, the emulator is not available here: $URL_FILE. Visit the website to download it manually."
      exit
  else
      sudo apt-get install -y libsdl1.2debian libsdl-image1.2 libsdl-ttf2.0-0 libguichan-0.8.1-1 libguichan-sdl-0.8.1-1
      mkdir -p $INSTALL_DIR
      wget $URL_FILE
      tar xzf uae4all2*
      rm -rf tar uae4all2*.tgz
      cd uae4all2/kickstarts
      wget $KICK_FILE && unzip Amiga_roms.zip && mv kick13.rom kick.rom && rm Amiga_roms.zip && cd ..
      wget http://www.emuparadise.me/GameBase%20Amiga/Games/T/Turrican.zip && unzip -o Turrican.zip && rm Turrican.zip
      sudo sh -c 'echo "@pi - rtprio 90" >> /etc/security/limits.conf'
      echo -e "Done!. Type ./uae4all2 and for Full Screen: ./amiga"
      read -p "Press [Enter] to continue..."
      exit
  fi

}

echo -e "UAE4All2 2.3.5.3 for Raspberry Pi\n=================================\n· More Info: http://www.raspberrypi.org/forums/viewtopic.php?f=78&t=80602\n· Kickstar ROMs & Turrican included.\n\nInstall path: $INSTALL_DIR"
while true; do
    echo " "
    read -p "Is it right? [y/n] " yn
    case $yn in
    [Yy]* ) echo "Installing, please wait..." && install;;
    [Nn]* ) changeInstallDir;;
    [Ee]* ) exit;;
    * ) echo "Please answer (y)es, (n)o or (e)xit.";;
    esac
done
