#!/bin/bash
#
# Description : UAE4ARM Amiga emulator
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.3 (08/Sep/16)
# Compatible  : Raspberry Pi 1, 2 & 3 (tested) Only run on X due a SDL issue
#
clear

. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"
UAE4ARM="https://www.dropbox.com/s/n7mvlp9pmxgzq9c/uae4arm-rpi.tar.gz?dl=0"
KICK_FILE="http://misapuntesde.com/res/Amiga_roms.zip"
GAME="http://www.emuparadise.me/GameBase%20Amiga/Games/T/Turrican.zip"
GAME2_DSK1="http://www.emuparadise.me/GameBase%20Amiga/Games/X/Xenon%202%20-%20Megablast_Disk1.zip"
GAME2_DSK2="http://www.emuparadise.me/GameBase%20Amiga/Games/X/Xenon%202%20-%20Megablast_Disk2.zip"

INPUT=/tmp/amigamenu.$$

trap 'rm $INPUT; exit' SIGHUP SIGINT SIGTERM

downloadKICK()
{
    wget $KICK_FILE && unzip Amiga_roms.zip && mv kick13.rom kick.rom && rm Amiga_roms.zip
}

downloadROM()
{
    wget $1 && unzip -o *.zip && rm *.zip
}

mkDesktopEntry(){
	if [[ ! -e ~/.local/share/applications/uae4arm.desktop ]]; then
cat << EOF > ~/.local/share/applications/uae4arm.desktop
[Desktop Entry]
Name=UAE4ARM
Exec=/home/pi/games/uae4arm-rpi/uae4arm
Icon=terminal
Type=Application
Comment=Amiga emulator port.
Categories=Game;
Path=/home/pi/games/uae4arm-rpi/
EOF
	fi
}

instUAE4ARM()
{
    if  which $INSTALL_DIR/uae4arm-rpi/uae4arm >/dev/null ; then
        read -p "Warning!: UAE4ARM already installed. Press [ENTER] to exit..."
        exit
    fi
    echo -e "UAE4ARM 0.5 for Raspberry Pi\n============================\n· More Info: https://github.com/midwan/uae4arm-rpi\n· Kickstar ROMs & Turrican included.\n· Install path: $INSTALL_DIR/uae4arm-rpi\n"
    read -p "Press [Enter] to continue..."
    SDL_fix_Rpi
    mkdir -p $INSTALL_DIR && cd $INSTALL_DIR
    wget -O uae4arm-rpi.tar.gz $UAE4ARM
    tar xzf uae4arm-rpi.tar.gz
    rm uae4arm-rpi.tar.gz
    cd uae4arm-rpi
    downloadROM $GAME
    cd kickstarts
    downloadKICK
    mkDesktopEntry
    echo -e "Done!. Type ./uae4arm"
    read -p "Press [Enter] to continue..."
    exit
}

compUAE4ARM() {
    echo "Installing dependencies..."
    sudo apt install -y libsdl-dev libguichan-dev libsdl-ttf2.0-dev libsdl-gfx1.2-dev libxml2-dev libflac-dev libmpg123-dev
    mkdir -p $HOME/games && cd $_
    echo "Cloning and compiling repo..."
    git clone https://github.com/midwan/uae4arm-rpi.git && cd uae4arm-rpi
    if [ $(uname -m) == 'armv7l' ]; then
        make
    else
        make PLATFORM=rpi1
    fi
    echo "Copying Rickstarts ROMs..."
    cd kickstarts
    wget $KICK_FILE && unzip Amiga_roms.zip && rm Amiga_roms.zip && cd ..
    echo -e "\nDone!. Type ./uae4arm and have fun. TIP: F12=Menu."
}
while true
do
    dialog --clear   \
        --title     "[ UAE4ARM Amiga emulators ]" \
        --menu      "Select from the list:" 11 65 3 \
        UAE4ARMI   "UAE4ARM 0.5 binary (Recommended)" \
        UAE4ARMC   "Compile uae4arm-rpi (latest). Time: 22 minutes." \
        Exit    "Exit" 2>"${INPUT}"

    menuitem=$(<"${INPUT}")

    case $menuitem in
        UAE4ARMI) clear ; instUAE4ARM ;;
        UAE4ARMC) clear ; compUAE4ARM ;;
        Exit) exit ;;
    esac
done
