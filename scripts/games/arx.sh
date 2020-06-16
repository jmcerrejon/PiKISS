#!/bin/bash
#
# Description : Arx Fatalis (a.k.a. Arx Libertatis)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.8 (19/May/15)
# Compatible  : Raspberry Pi 2 (tested: Fail textures), ODROID-C1 (OK), Debian (OK)
# Know bugs   : Maybe with libglew
#
clear

. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

ARX_RPI_URL="https://pickle.gp2x.de/rpi/quake2_rpi.zip"
ARX_PAK_URL="https://www.dropbox.com/s/7416ye9qi0024pu/arx_full_es.tgz?dl=0"
DATA_DIR="$HOME/games/"
LICENSE="Complete"
ARX_ODROID_PKG="https://misapuntesde.com/res/arx-libertatis_1.1.2-1_armhf.deb"
ARX_RPI_BIN="https://www.littlecarnage.com/arx_rpi2.tar.gz"

share_version(){
  ARX_PAK_URL="https://www.dropbox.com/s/nhh3lr8irrx3vnm/arx_demo_en.tgz?dl=0"
}

dload_pak_files(){
  if [ ! -d $HOME/.config/arx ]; then
  wget -O $HOME/arx.tgz $ARX_PAK_URL
  cd $HOME
  tar xzvf $HOME/arx.tgz
  rm $HOME/arx.tgz
fi
}

arx_ODROID(){
  DATA_DIR="$HOME/.yq2"

  if [ ! -f /etc/apt/sources.list.d/meveric-all-testing.list ]; then
    sudo wget -P /etc/apt/sources.list.d https://oph.mdrjr.net/meveric/sources.lists/meveric-all-testing.list
    sudo wget -O- https://oph.mdrjr.net/meveric/meveric.asc | sudo apt-key add -
    sudo apt-get update
  fi
  command -v arx >/dev/null 2>&1 || { sudo apt-get install -y libglew-odroid ; wget -P $HOME $ARX_ODROID_PKG ; }
}

arx_Raspberry(){

  # Check if SDL is fixed to RPi2
  SDL_fix_Rpi

  [ ! -d $DATA_DIR ] && mkdir -p $DATA_DIR
  cd $DATA_DIR
  wget -P $DATA_DIR $ARX_RPI_BIN
  tar xzvf $DATA_DIR/arx_rpi2.tar.gz
  rm $DATA_DIR/arx_rpi2.tar.gz
  sudo apt-get install -y libglew1.7
  read -p "Press [Enter] to continue..."
}

arx_Debian(){
  sudo sh -c "echo 'deb https://download.opensuse.org/repositories/home:/dscharrer/Debian_8.0/ ./' >> /etc/apt/sources.list"
  wget -P ~ https://download.opensuse.org/repositories/home:dscharrer/Debian_8.0/Release.key
  sudo sh -c "apt-key add - < Release.key"
  rm ~/Release.key
  sudo apt update
  sudo apt install -y arx-libertatis
}

echo -e "Installing Arx Libertatis\n=========================\n\n· Version 1.1.2\n· 720p (You can change that)\n·For Raspberry Pi 2: This port is not a final release nor is it free from bugs! It should only demonstrate that it is indeed possible to get Arx Libertatis working on the slim hardware that is a Raspberry Pi 2\n\n"

if [[ ${MODEL} == 'Raspberry Pi' ]]; then
  arx_Raspberry
elif [[ ${MODEL} == 'ODROID-C1' ]]; then
  arx_ODROID
elif [[ ${MODEL} == 'Debian' ]]; then
  arx_Debian
fi

dialog --title     "[ Arx Fatalis. PAK License ]" \
  --yes-label "Shareware (155 MB)" \
  --no-label  "Complete (Spanish - 526 MB)" \
  --yesno     "Choose what type of PAK files do you want to install. NOTE: For complete version, you must be the owner of the original game (in some countries)" 7 80

retval=$?

case $retval in
  0)   share_version ; LICENSE="Shareware";;
  255) exit ;;
esac

echo -e "\n\nDownloading...\n"

dload_pak_files

read -p "run with: arx. Press [Enter] to continue..."
