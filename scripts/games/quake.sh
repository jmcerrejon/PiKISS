#!/bin/bash
#
# Description : Quake Pack (Install Quake 1/2/3/Server Ed, DarkPlace)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.7 (27/Mar/15)
# Compatible  : Raspberry Pi 1 & 2 (tested), ODROID-C1 (tested)
# Know bugs   : RPi with the latest Raspbian: black screen | ODROID can't change 640x480 resolution
#
# HELP    
#             · Quake 1: https://github.com/welford/qurp    
#             · QuakeServer: http://www.recantha.co.uk/blog/?p=9962
#             · Darkplaces Quake: http://www.raspberrypi.org/forums/viewtopic.php?t=72301
#             · http://www.raspberrypi.org/forums/viewtopic.php?f=78&t=18853
#             · http://www.raspberrypi.org/forums/viewtopic.php?f=78&t=54683
#
clear

. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

Q1_DEMO_PAK_URL="http://www.quakeforge.net/files/quake-shareware-1.06.zip"
QUAKE2_RPI_URL="http://pickle.gp2x.de/rpi/quake2_rpi.zip"
Q2_PAK_URL="http://www.dropbox.com/s/bh5co9nnmy0xf0n/baseq2.zip?dl=0"
Q2_CONFIG_URL="https://raw.githubusercontent.com/jmcerrejon/PiKISS/master/res/config.cfg"
Q3_DEMO_PAK_URL="http://joshua14.homelinux.org/downloads/Q3-Demo-Paks.zip"
DATA_DIR="$HOME/games/quake2"
EXEC="$DATA_DIR/quake2"

quake2_ODROID(){
  DATA_DIR="$HOME/.yq2"
  EXEC="yquake2 in a Terminal or Menu > Games > Quake 2"
  sudo wget -P /etc/apt/sources.list.d http://oph.mdrjr.net/meveric/sources.lists/meveric-all-testing.list
  sudo wget -O- http://oph.mdrjr.net/meveric/meveric.asc | sudo apt-key add -
  sudo apt-get update
  sudo apt-get install -y yquake2-odroid libglew-odroid
  [ ! -d $DATA_DIR/baseq2 ] && mkdir -p $DATA_DIR/baseq2
  cp /usr/local/share/yquake2/baseq2/game.so $DATA_DIR/baseq2
  wget -P $DATA_DIR/baseq2 $Q2_CONFIG_URL
  #cd /usr/lib/arm-linux-gnueabihf/ && sudo ln -sf libEGL.so.1 libEGL.so
}

quake2_Raspberry(){
  [ ! -d $DATA_DIR ] && mkdir -p $DATA_DIR
  wget -P $DATA_DIR $QUAKE2_RPI_URL
  unzip $DATA_DIR/quake2_rpi.zip -d $DATA_DIR
  rm $DATA_DIR/quake2_rpi.zip
}

quakeServer(){
    wget http://downloads.sourceforge.net/project/nquake/nQuakesv%20%28Linux%29/v1.3/nquakesv13_installer.tar.gz
    tar xzvc nquakesv13_installer.tar.gz
    cd nquakesv13_installer/
    ./install_nquakesv.sh
    # Unfinished...
    ./run/port1.sh
}

echo -e "Installing Quake 2\n==================\n·Know issues:\n· RPi: Black screen on latest Raspbian.\n· ODROID: 640x480 square box if your resolution is higher.\n\n"

if [[ ${MODEL} == 'Raspberry Pi' ]]; then
  quake2_Raspberry
elif [[ ${MODEL} == 'ODROID-C1' ]]; then
  quake2_ODROID
fi

dialog   --title     "[ Download Quake2 .PAK files ]" \
         --yes-label "Yes" \
         --no-label  "No" \
         --yesno     "You need the .PAK files from the original game. Do you want I download it for you (99 MB)? (In some countries the laws may consider it like piracy software)" 7 55

retval=$?

case $retval in
  0)   echo -e "Installing...\n" ;;
  1)   clear ; read -p "Please copy into $DATA_DIR/baseq2 all the .pak files from the original game and run with: $EXEC. Press [Enter] to continue..." ; exit ;;
esac
#wget -P $HOME/.yq2 -O baseq2.zip http://www.dropbox.com/s/bh5co9nnmy0xf0n/baseq2.zip?dl=0 && unzip $HOME/baseq2.zip -d $HOME/.yq2
wget -P $DATA_DIR -O baseq2.zip $Q2_PAK_URL
unzip $HOME/baseq2.zip -d $DATA_DIR
rm $HOME/baseq2.zip

read -p "Press [Enter] to continue..."