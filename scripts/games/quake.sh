#!/bin/bash
#
# Description : Quake Pack (Install Quake 1/2/3/Server Ed, DarkPlace)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.4 (06/Jun/14)
#
# HELP        · quakeServer: http://www.recantha.co.uk/blog/?p=9962
#             · Darkplaces Quake: http://www.raspberrypi.org/forums/viewtopic.php?t=72301
clear

QUAKE2_URL="http://pickle.gp2x.de/rpi/quake2_rpi.zip"
Q2_PAK_URL="http://download1721.mediafire.com/nldd8l6yzqzg/zcfktp5izjl68rj/quake2+PAK.rar"
DATA_DIR=$HOME"/games"

quakeServer(){
    wget http://downloads.sourceforge.net/project/nquake/nQuakesv%20%28Linux%29/v1.3/nquakesv13_installer.tar.gz
    tar xzvc nquakesv13_installer.tar.gz
    cd nquakesv13_installer/
    ./install_nquakesv.sh
    # Unfinished...
    ./run/port1.sh
}

echo "Installing Quake 2..."
wget -P /tmp $QUAKE2_URL
mkdir -p $HOME/quake2
unzip /tmp/quake2_rpi.zip -d $DATA_DIR/quake2

dialog --backtitle "piKiss" \
         --title     "[ Download Quake ]" \
         --yes-label "Yes" \
         --no-label  "No" \
         --yesno     "You need the original .PAK files from the original game. Do you want to download? (In some countries the laws may consider it like pirate software)" 7 55

  retval=$?

  case $retval in
    0)   echo -e "Installing...\n" ;;
    1)   clear ; read -p "Please copy into ~/games/quake2/baseq2 all the .pak files from the original game and run with: "$DATA_DIR"/quake2/quake2. Press [Enter] to continue..." ; exit ;;
  esac

wget -P /tmp -O quake2.rar $Q2_PAK_URL
rar x /tmp/quake2.rar $DATA_DIR *.pak

# Cleaning the House
rm /tmp/quake2.rar
rm /tmp/quake2_rpi.zip

read -p "Press [Enter] to continue..."