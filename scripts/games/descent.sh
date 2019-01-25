#!/bin/bash
#
# Description : Descent 1 & 2 thks to DXX-Rebirth v0.60-weekly-04-14-18
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9.0 (25/Jan/19)
# Compatible  : Raspberry Pi 1,2 & 3 B+ (tested)
#
# HELP	      : https://github.com/dxx-rebirth/dxx-rebirth
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

D1X_SHARE_URL='https://www.dxx-rebirth.com/download/dxx/content/descent-pc-shareware.zip'
D2X_SHARE_URL='https://www.dxx-rebirth.com/download/dxx/content/descent2-pc-demo.zip'
DXX_URL='https://www.dropbox.com/s/mid0zs4bo3e3i0b/dxx-rebirth.tar.gz?dl=0'
D1X_HIGH_TEXTURE_URL='http://www.dxx-rebirth.com/download/dxx/res/d1xr-hires.dxa'
D1X_OGG_URL='http://www.dxx-rebirth.com/download/dxx/res/d1xr-sc55-music.dxa'
D2X_OGG_URL='http://www.dxx-rebirth.com/download/dxx/res/d2xr-sc55-music.dxa'
D1X_DATA="$HOME/.d1x-rebirth/Data"
D2X_DATA="$HOME/.d2x-rebirth/Data"
BINARY_DIR='/usr/games'
GAME_DIR='/usr/share/games'

if  which /usr/games/d1x-rebirth >/dev/null ; then
    read -p "Warning!: D1X Rebirth already installed. Press [ENTER] to exit..."
    exit;
fi

if  which /usr/games/d2x-rebirth >/dev/null ; then
    read -p "Warning!: D2X Rebirth already installed. Press [ENTER] to exit..."
    exit
fi

generateIconsD1X(){
    if [[ ! -e ~/.local/share/applications/d1x.desktop ]]; then
cat << EOF > ~/.local/share/applications/d1x.desktop
[Desktop Entry]
Name=Descent 1
Exec=/usr/games/d1x-rebirth
Icon=terminal
Type=Application
Comment=The game requires the player to navigate labyrinthine mines while fighting virus-infected robots.
Categories=Game;ActionGame;
EOF
    fi
}

generateIconsD2X(){
    if [[ ! -e ~/.local/share/applications/d2x.desktop ]]; then
cat << EOF > ~/.local/share/applications/d2x.desktop
[Desktop Entry]
Name=Descent 2
Exec=/usr/games/d2x-rebirth
Icon=terminal
Type=Application
Comment=Complete 24 levels where different types of AI-controlled robots will try to destroy you.
Categories=Game;ActionGame;
EOF
    fi
}

setConfigFileReadyToPlay(){
    clear && echo -e "You need to modify /boot/config.txt commenting #dtoverlay=vc4-fkms-v3d, #dtoverlay=vc4-kms-v3d and gpu_mem=128"
    # TODO: Make this step automatically
}

DXX_RPI(){
    # Compile from source code needs sudo apt install -y libsdl1.2-dev libsdl-mixer1.2-dev libphysfs-dev
    sudo apt install -y libphysfs1
    # Binaries
    sudo wget -O $BINARY_DIR/dxx-rebirth.tar.gz $DXX_URL
    cd $BINARY_DIR
    sudo tar -xzvf $BINARY_DIR/dxx-rebirth.tar.gz
    # Shareware demo datas
    wget -P $D1X_DATA $D1X_SHARE_URL
    wget -P $D2X_DATA $D2X_SHARE_URL
    unzip -d $D1X_DATA $D1X_DATA/descent-pc-shareware.zip
    unzip -d $D2X_DATA $D2X_DATA/descent2-pc-demo.zip
    # Some extra addons to improve the game experience ;)
    clear && echo -e "\nInstalling HIGH textures quality pack...\n\nPlease wait...\n" && sudo wget -P $D1X_DATA $D1X_HIGH_TEXTURE_URL
    echo -e "\n\nInstalling OGG Music for better experience...\n\n· All music was recorded with the Roland Sound Canvas SC-55 MIDI Module.\n\nPlease wait...\n" && sudo wget -P $D1X_DATA $D1X_OGG_URL && sudo wget -P $D2X_DATA $D2X_OGG_URL
    # Cleaning da house
    sudo rm $BINARY_DIR/dxx-rebirth.tar.gz $D1X_DATA/descent-pc-shareware.zip $D2X_DATA/descent2-pc-demo.zip
    # Icons & info
    generateIconsD1X
    generateIconsD2X
    setConfigFileReadyToPlay
}

echo -e "Installing DXX-Rebirth...\n=========================\n\n· Please wait...\n"

DXX_RPI

read -p "Done!. type /usr/games/d1x-rebirth or /usr/games/d2x-rebirth to Play or go to Desktop Game Menu option. Press [ENTER] to continue..."
