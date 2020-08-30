#!/bin/bash
#
# Description : MS-DOS Emulator DOSBox-X
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.2 (29/Aug/20)
#
# Help        : https://krystof.io/dosbox-shaders-comparison-for-modern-dos-retro-gaming/
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="/home/$USER/games"
URL_FILE="https://misapuntesde.com/rpi_share/dosbox-X_0-82.26.tar.gz"

if  which $INSTALL_DIR/dosbox >/dev/null ; then
    read -p "Warning!: Dosbox already installed. Press [ENTER] to exit..."
    exit
fi

mkDesktopEntry() {
	if [[ ! -e /usr/share/applications/dosbox-x.desktop ]]; then
		sudo sh -c 'echo "[Desktop Entry]\nName=DOSBox-X\nComment=Cross-platform DOS emulator\nExec='$INSTALL_DIR'/dosbox/dosbox-x\nIcon='$INSTALL_DIR'/dosbox/dosbox.png\nTerminal=false\nType=Application\nCategories=Application;Game;\nPath='$INSTALL_DIR'/dosbox" > /usr/share/applications/dosbox-x.desktop'
	fi
}

validate_url() {
    if [[ `wget -S --spider $1 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then echo "true"; fi
}

extra() {
   local URL_FILE="https://misapuntesde.com/res/jill-of-the-jungle-the-complete-trilogy.zip"
   if [[ $(validate_url $URL_FILE) != "true" ]]; then
       echo "Sorry, the game is not available here: $URL_FILE."
   else
       echo -e "\nInstalling the game..."
       mkdir -p $INSTALL_DIR/dosbox/dos/jill && cd $_
       wget -qO- -O jill.zip $URL_FILE && unzip -o jill.zip && rm jill.zip
   fi
}

playgame() {
	read -p "Do you want to run DOSBox-X right now? [y/n] " option
	case "$option" in
		y*) cd $INSTALL_DIR/dosbox && ./dosbox-x ;;
	esac
}

install() {
    if [[ $(validate_url $URL_FILE) != "true" ]] ; then
        echo "Sorry, the emulator is not available here: $URL_FILE. Visit the website to download it manually."
        exit
    else
		mkdir -p $HOME/.dosbox && cp ./res/dosbox-0.82.26.conf $HOME/.dosbox/dosbox-0.82.26.conf
        mkdir -p $INSTALL_DIR && cd $_
        wget -qO- -O tmp.tar.gz $URL_FILE && tar -xzvf tmp.tar.gz && rm tmp.tar.gz
		cd dosbox && mkdir -p dos
		mkDesktopEntry
        echo -e "\nDone!. Put your games inside $INSTALL_DIR/dosbox/dos. To play, go to $INSTALL_DIR/dosbox and type: ./dosbox-x\n"
        read -p "EXTRA!: Do you want to download Jill of The Jungle Trilogy to play with DOSBox-X? [y/n] " option
        case "$option" in
            y*) echo -e "\nInstalling, please wait..." && extra;;
        esac
    fi
    playgame
    read -p "Press [Enter] to go back to the menu..."
    exit
}

echo -e "DOSBox-X MS-DOS Emulator\n========================\n· More Info: https://github.com/joncampbell123/dosbox-x\n\n· Install path: $INSTALL_DIR/dosbox"
while true; do
    echo " "
    read -p "Proceed? [y/n] " yn
    case $yn in
    [Yy]* ) echo -e "\nInstalling, please wait..." && install;;
    [Nn]* ) exit;;
    [Ee]* ) exit;;
    * ) echo "Please answer (y)es, (n)o or (e)xit.";;
    esac
done
