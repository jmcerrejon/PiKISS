#!/bin/bash
#
# Description : Gameboy Advance emulator thanks to DPR
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.2 (07/Sep/16)
# Compatible  : Raspberry Pi 1 & 2 (tested)
#
# HELP        · http://www.raspberrypi.org/forums/viewtopic.php?f=78&t=37433
#
clear

. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"
URL_FILE="https://www.dropbox.com/s/u3wjlbdp4kav5kg/gpsp.tar.gz"
GAME_URL='http://computeremuzone.com/contador.php?f_ad=watman_gba.zip&n_ar=Watman%20(Batman%20remake)%20(GBA)&dd=consolas/gba&f=593&sis=gba'

playgame()
{
    if [[ -f $HOME/games/gpsp/watman.zip ]]; then
        read -p "Do you want to play Watman now? [y/n] " option
        case "$option" in
            y*) cd $HOME/games/gpsp && ./gpsp watman.zip ;;
        esac
    fi
}

install()
{
    if [[ ! -f $HOME/games/gpsp/gpsp ]]; then
        #sudo apt-get install -y libsdl1.2debian libsdl-mixer1.2 libsdl-ttf2.0-0
        SDL_fix_Rpi
        mkdir -p $INSTALL_DIR && cd $_
        wget -4 -qO- -O tmp.tar.gz $URL_FILE && tar xzf tmp.tar.gz && rm tmp.tar.gz
        cd gpsp/
        wget -O watman.zip $GAME_URL
    fi
    echo "Done!. To play, go to install path and type: ./gpsp"
    playgame

    read -p "Press [Enter] to continue..."
    exit
}

echo -e "Gameboy Advance Emulator (gpsp)\n===============================\n\n· More Info: http://www.raspberrypi.org/forums/viewtopic.php?f=78&t=37433\n· Batman by OCEAN remake included. More info: http://computeremuzone.com/ficha.php?id=593&l=en\n· It works with compressed roms (.zip)\n· Install path: $INSTALL_DIR/gpsp\n\nInstalling, please wait..."
install
