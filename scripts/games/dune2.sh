#!/bin/bash
#
# Description : Download & Install Dune 2
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (12/May/14)
#
clear
DATA_DIR="$HOME/.config/dunelegacy/data"
DUNE2_GAME="http://www.bestoldgames.net/download/bgames/dune-2.zip"

# Dune 2 Legacy
echo "Downloading Dune Legacy..."
wget -O /tmp/dune2.deb http://www.pandemonium.be/file.php?name=4CE6FC4D6F4F099949A6F42C9473073C5D0916D81CFFDCDD3CD53C10EE90AFB5
sudo dpkg -i /tmp/dune2.deb

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
