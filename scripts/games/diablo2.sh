#!/bin/bash
#
# Description : Diablo 2 Exp. Spanish for Raspberry Pi
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (16/Nov/19)
# Compatible  : Raspberry Pi 3-4 (tested)
#
# Info		  : Thks to PI LAB
# Help		  : xrandr --newmode "800x600_60.00"  38.25  800 832 912 1024 600 603 607 624 -hsync +vsync or xrandr --newmode HDMI-1 800x600_60.00
#

. ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

D2_PATH='https://archive.org/download/diabl02sp/diablo2.tar.xz'
GAMES_PATH="$HOME/games"
SCRIPT_PATH="$HOME/games/diablo2/diablo2.sh"

generateIconDiablo2(){
    if [[ ! -e ~/.local/share/applications/diablo2.desktop ]]; then
cat << EOF > ~/.local/share/applications/diablo2.desktop
[Desktop Entry]
Name=Diablo 2 Lod of Destruction
Exec=/home/pi/games/diablo2/diablo2.sh
Icon=terminal
Type=Application
Comment=Set in the fictional Kingdom of Khanduras in the mortal realm, Diablo makes the player take control of a lone hero battling to rid the world of Diablo
Categories=Game;ActionGame;
EOF
    fi
}

install(){
	if ! isPackageInstalled wine; then
		sudo apt install -y wine
	fi
	copyGPUDriversByPILAB
	if [ ! -d $HOME/games/diablo2 ]; then
		wget $D2_PATH
		mkdir -p $GAMES_PATH && cd $_
		tar xvf diablo2.tar.xz
		rm diablo2.tar.xz
	fi
	touch $SCRIPT_PATH 
	bash -c "echo 'LD_LIBRARY_PATH=/home/pi/mesa/lib/arm-linux-gnueabihf LIBGL_DRIVERS_PATH=/home/pi/mesa/lib/arm-linux-gnueabihf/dri/ GBM_DRIVERS_PATH=/home/pi/mesa/lib setarch linux32 -L wine libd2game_sa_arm.exe.so /desktop=Diablo2,800x600' > ${SCRIPT_PATH}"
	chmod +x $SCRIPT_PATH
}

install
generateIconDiablo2

read -p "Done!. Open Terminal, type winecfg and set resolution 800X600. Run $SCRIPT_PATH. Press [ENTER] to continue..."

