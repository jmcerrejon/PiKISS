#!/bin/bash
#
# Description : OpenMSX emulator 0.11.0
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0
#
# Quiero dar las gracias a *Patrick (VampierMSX)* del **OpenMSX Team** por ponerse en contacto conmigo para agregar a la web del equipo el emulador que he compilado para la Raspberry Pi.

clear
SC_OPENMSX="http://downloads.sourceforge.net/openmsx/openmsx-0.11.0.tar.gz"

# ROM game Thanks to msx.ebsoft.fr
ROM_PATH="http://msx.ebsoft.fr/uridium/ccount/click.php?id=uridium"

compile(){
	sudo apt-get install -y libsdl1.2-dev libsdl-ttf2.0-dev libglew-dev libao-dev libogg-dev libtheora-dev libxml2-dev libvorbis-dev tcl-dev gcc-4.7 g++-4.7
	sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.7 40 --slave /usr/bin/g++ g++ /usr/bin/g++-4.7
	clear
	echo "Now choose below: /usr/bin/gcc-4.7"
	sudo update-alternatives --config gcc 
	wget -O openmsx_sc.tar.gz $SC_OPENMSX
	tar xzvf openmsx*
	cd openmsx*
	export CXX=g++-4.7
	./configure
	make
	sudo make install
	wget -O /tmp/uridium.zip $ROM_PATH
}

compile

read -p "Done! Press [ENTER] to continue..."