#!/bin/bash
#
# Description : Quake Pack (Install Quake 1/2/3/Server Ed, DarkPlace)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.7.3 (27/Mar/15)
# Compatible  : Raspberry Pi 1 & 2 (tested), ODROID-C1 (tested)
# Know bugs   : RPi with the latest Raspbian: black screen | ODROID can't change 640x480 resolution
#
# HELP
#             · Quake 1: https://github.com/welford/qurp
#             · QuakeServer: http://www.recantha.co.uk/blog/?p=9962
#             · Darkplaces Quake: http://www.raspberrypi.org/forums/viewtopic.php?t=72301
#             · http://www.raspberrypi.org/forums/viewtopic.php?f=78&t=18853
#             · http://www.raspberrypi.org/forums/viewtopic.php?f=78&t=54683
#             · http://forums.steampowered.com/forums/showthread.php?t=996272 | http://quake.wikia.com/wiki/Quake_2_Soundtrack
#
clear

. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

Q1_DEMO_PAK_URL="http://www.quakeforge.net/files/quake-shareware-1.06.zip"
QUAKE2_RPI_URL="http://pickle.gp2x.de/rpi/quake2_rpi.zip"
Q2_PAK_URL="http://www.dropbox.com/s/bh5co9nnmy0xf0n/baseq2.zip?dl=0"
Q2_OGG_URL="https://www.dropbox.com/s/z7c8lm8weemf2iy/q2_ogg.zip?dl=0"
Q2_CONFIG_URL="https://raw.githubusercontent.com/jmcerrejon/PiKISS/master/res/config.cfg"
Q3_DEMO_PAK_URL="http://joshua14.homelinux.org/downloads/Q3-Demo-Paks.zip"
DATA_DIR="$HOME/games/quake2"
EXEC="$DATA_DIR/quake2"
LICENSE="Complete"

quake2_ODROID(){
  DATA_DIR="$HOME/.yq2"
  EXEC="yquake2 in a Terminal or Menu > Games > Quake 2"
  if [ ! -f /etc/apt/sources.list.d/meveric-all-testing.list ]; then
    sudo wget -P /etc/apt/sources.list.d http://oph.mdrjr.net/meveric/sources.lists/meveric-all-testing.list
    sudo wget -O- http://oph.mdrjr.net/meveric/meveric.asc | sudo apt-key add -
    sudo apt-get update
  fi
  command -v yquake2 >/dev/null 2>&1 || { sudo apt-get install -y yquake2-odroid libglew-odroid; }
  [ ! -d $DATA_DIR/baseq2 ] && mkdir -p $DATA_DIR/baseq2
  cp /usr/local/share/yquake2/baseq2/game.so $DATA_DIR/baseq2
  wget -P $DATA_DIR/baseq2 $Q2_CONFIG_URL
  #cd /usr/lib/arm-linux-gnueabihf/ && sudo ln -sf libEGL.so.1 libEGL.so
}
[! -f /etc/apt/sources.list.d/meveric-all-testing.list ] && { echo "1" && echo "2" }

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

share_version(){
  Q2_PAK_URL="https://www.dropbox.com/s/sbr0xwr9wo9been/baseq2s.zip?dl=0"
}

echo -e "Installing Quake 2\n==================\n\n· OGG soundtrack\n· 720p (You can change that)\n· Know issues:\n· RPi: Black screen on latest Raspbian without X display.\n\n"

if [[ ${MODEL} == 'Raspberry Pi' ]]; then
  quake2_Raspberry
elif [[ ${MODEL} == 'ODROID-C1' ]]; then
  quake2_ODROID
fi

dialog --title     "[ Quake II. PAK License ]" \
  --yes-label "Shareware" \
  --no-label  "Complete" \
  --yesno     "Choose what type of PAK files do you want to install. NOTE: For complete version, you must be the owner of the original game (in some countries)" 7 55

retval=$?

case $retval in
  0)   share_version ; LICENSE="Shareware";;
  255) exit ;;
esac

echo -e "\n\nDownloading...\n" ;;
#wget -P $HOME/.yq2 -O baseq2.zip http://www.dropbox.com/s/bh5co9nnmy0xf0n/baseq2.zip?dl=0 && unzip $HOME/baseq2.zip -d $HOME/.yq2
wget -P $HOME -O baseq2.zip $Q2_PAK_URL
wget -P $HOME -O q2_ogg.zip $Q2_OGG_URL
unzip $HOME/baseq2.zip -d $DATA_DIR
unzip $HOME/q2_ogg.zip -d $DATA_DIR/baseq2
rm $HOME/baseq2.zip $HOME/q2_ogg.zip

read -p "run with: $EXEC.Press [Enter] to continue..."