#!/bin/bash
#
# Description : Download & Install Dune 2
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.2 (14/Jan/18)
# Compatible  : Raspberry Pi 1,2 & 3 (tested)
#
clear
DATA_DIR="$HOME/.config/dunelegacy/data"
DUNE2_GAME="http://www.bestoldgames.net/download/bgames/dune-2.zip"

# Dune 2 Legacy
echo "Downloading Dune Legacy..."
wget -O /tmp/dunelegacy_0.96.4_armhf.deb https://sourceforge.net/projects/dunelegacy/files/dunelegacy/0.96.4/dunelegacy_0.96.4_armhf.deb/download
sudo dpkg -i /tmp/dunelegacy_0.96.4_armhf.deb

#echo "Installing dependencies..."
#sudo apt install -y libSDL-mixer1.2

dialog --backtitle "piKiss" \
         --title     "[ Download Dune 2 Abandonware ]" \
         --yes-label "Yes" \
         --no-label  "No" \
         --yesno     "You need the original .PAK files from the original game. Do you want to download? (In some countries the laws may consider it pirate software)" 7 55

  retval=$?

  case $retval in
    0)   echo -e "Installing...\n" ;;
    1)   clear ; read -p "Please copy into ~/.config/dunelegacy/data all the .PAK files from the original game and run with: dunelegacy. Press [Enter] to continue..." ; exit ;;
  esac

# Dune 2 Abandonware borrowed from bestoldgames.net
wget -O /tmp/dune2.zip $DUNE2_GAME

mkdir -p $DATA_DIR
unzip /tmp/dune2.zip -d $DATA_DIR *.PAK

# Cleaning the House
rm /tmp/dune2.*

echo -e "\nType dunelegacy to play the game. Enjoy!"
read -p "Press [Enter] to continue..."
