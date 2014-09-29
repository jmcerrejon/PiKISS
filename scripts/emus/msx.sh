#!/bin/bash
#
# Description : MSX emulator
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.1
#
clear
SC_OPENMSX="http://sourceforge.net/projects/openmsx/files/latest/download?source=files"

# ROM game Thanks to msx.ebsoft.fr
ROM_PATH="http://msx.ebsoft.fr/uridium/ccount/click.php?id=uridium"

compile(){
	sudo apt-get install -y libsdl1.2-dev libsdl-ttf2.0-dev libglew-dev libao-dev libogg-dev libtheora-dev libxml2-dev libvorbis-dev tcl-dev
	wget -O openmsx_sc.tar.gz $SC_OPENMSX
	tar xzvf openmsx*
	cd openmsx*
	./configure
	make
	sudo make install
	wget -O /tmp/uridium.zip $ROM_PATH
}

compile

read -p "Done! Press [ENTER] to continue..."