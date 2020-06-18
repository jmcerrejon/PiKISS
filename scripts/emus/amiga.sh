#!/bin/bash
#
# Description : Amiberry Amiga emulator
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.4 (18/Jun/20)
# Compatible  : Raspberry Pi 1-4
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }
clear

INSTALL_DIR="$HOME/games"
AMIBERRY_PI4="https://github.com/midwan/amiberry/releases/download/v3.1.3.1/amiberry-rpi4-v3.1.3.1.zip"
KICK_FILE="https://misapuntesde.com/res/Amiga_roms.zip"
GAME="https://www.emuparadise.me/GameBase%20Amiga/Games/T/Turrican.zip"
GAME2_DSK1="https://www.emuparadise.me/GameBase%20Amiga/Games/X/Xenon%202%20-%20Megablast_Disk1.zip"
GAME2_DSK2="https://www.emuparadise.me/GameBase%20Amiga/Games/X/Xenon%202%20-%20Megablast_Disk2.zip"

INPUT=/tmp/amigamenu.$$

trap 'rm $INPUT; exit' SIGHUP SIGINT SIGTERM

downloadKICK() {
	echo -e "\nCopying Rickstarts ROMs...\n"
	cd kickstarts
    wget $KICK_FILE && unzip Amiga_roms.zip && mv kick13.rom kick.rom && rm Amiga_roms.zip
}

downloadROM() {
    wget $GAME && unzip -o *.zip && rm *.zip
}

mkDesktopEntry() {
	if [[ ! -e ~/.local/share/applications/amiberry.desktop ]]; then
cat << EOF > ~/.local/share/applications/amiberry.desktop
[Desktop Entry]
Name=Amiberry
Exec=/home/pi/games/amiberry/amiberry
Icon=terminal
Type=Application
Comment=Amiga emulator port.
Categories=Game;
Path=/home/pi/games/amiberry/
EOF
	fi
}

instAMIBERRY() {
    if  [[ -e $INSTALL_DIR/amiberry/amiberry ]]; then
        read -p "Amiberry already installed. Press [ENTER] to go back to menu..."
        exit
    fi
    echo -e "Amiberry for Raspberry Pi\n=========================\n· More Info: https://github.com/midwan/amiberry\n· Kickstar ROMs & Turrican included.\n· Install path: $INSTALL_DIR/amiberry\n"
    mkdir -p $INSTALL_DIR && cd $_
    wget $AMIBERRY_PI4
    unzip amiberry-rpi4-sdl2-v3.1.3.1.zip -d ./amiberry
    rm amiberry-rpi4-sdl2-v3.1.3.1.zip
    cd amiberry
	chmod +x amiberry
    downloadROM
    downloadKICK
    mkDesktopEntry
    echo -e "Done!. Go to $INSTALL_DIR/amiberry and type: ./amiberry"
    read -p "Press [Enter] to go back to menu..."
    exit
}

compAMIBERRY() {
    echo "Installing dependencies..."
    sudo apt install -y libsdl-dev libguichan-dev libsdl-ttf2.0-dev libsdl-gfx1.2-dev libxml2-dev libflac-dev libmpg123-dev
    mkdir -p $HOME/games && cd $_
    echo "Cloning and compiling repo..."
    git clone https://github.com/midwan/amiberry.git amiberry && cd $_
    if [ $(uname -m) == 'armv7l' ]; then
        make
    else
        make PLATFORM=rpi1
    fi
    downloadKICK
    echo -e "\nDone!. Type ./amiberry and have fun. TIP: F12=Menu."
}

menu() {

while true
do
    dialog --clear   \
        --title     "[ Amiberry Amiga emulator for Raspberry Pi 4 ]" \
        --menu      "Select from the list:" 11 65 3 \
        AMIBERRYI   "Amiberry binary (Recommended)" \
        AMIBERRYC   "Compile Amiberry (latest). Time: ~22 minutes." \
        Exit    "Exit" 2>"${INPUT}"

    menuitem=$(<"${INPUT}")

    case $menuitem in
        AMIBERRYI) clear ; instAMIBERRY ;;
        AMIBERRYC) clear ; compAMIBERRY ;;
        Exit) exit ;;
    esac
done
}

menu
