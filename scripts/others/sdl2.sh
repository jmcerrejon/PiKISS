#!/bin/bash
#
# Description : Compile SDL 2.0.3
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.3 (3/Apr/15)
#
# Help        · https://github.com/jlnr/gosu/wiki/Getting-Started-on-Raspbian-%28Raspberry-Pi%29
#
clear

Install_BIN_RPi(){
	echo -e "Installing SDL 2.03 thanks to exobuzz\n====================================="
	wget -P $HOME http://malus.exotica.org.uk/~buzz/pi/sdl/sdl2/libsdl2-dbg_2.0.3_armhf.deb
	wget -P $HOME http://malus.exotica.org.uk/~buzz/pi/sdl/sdl2/libsdl2-dev_2.0.3_armhf.deb
	wget -P $HOME http://malus.exotica.org.uk/~buzz/pi/sdl/sdl2/libsdl2_2.0.3_armhf.deb
	sudo dpkg -i $HOME/libsdl2_2.0.3_armhf.deb
	sudo dpkg -i $HOME/libsdl2-dbg_2.0.3_armhf.deb
	sudo dpkg -i $HOME/libsdl2-dev_2.0.3_armhf.deb
sudo rm $HOME/libsdl2_2.0.3_armhf.deb $HOME/libsdl2-dev_2.0.3_armhf.deb $HOME/libsdl2-dev_2.0.3_armhf.deb
}

Compile_SDL_RPi(){
	echo -e "Compile SDL 2.03 + ttf + image + mixer\n======================================\nIt can take 40 min. Be patience...\n"

	# sudo apt install -y build-essential xorg-dev libudev-dev libts-dev libgl1-mesa-dev libglu1-mesa-dev libasound2-dev libpulse-dev libopenal-dev libogg-dev libvorbis-dev libaudiofile-dev libpng12-dev libfreetype6-dev libusb-dev libdbus-1-dev zlib1g-dev libdirectfb-dev
	sudo apt-get install -y libudev-dev libasound2-dev libdbus-1-dev libraspberrypi0 libraspberrypi-bin libraspberrypi-dev

	wget http://www.libsdl.org/release/SDL2-2.0.3.zip
	wget https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-2.0.12.zip
	wget https://www.libsdl.org/projects/SDL_image/release/SDL2_image-2.0.0.zip
	wget https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-2.0.0.zip

	unzip \*.zip

	cd SDL2-2.*
	./configure && make && sudo make install
	cd ..
	cd SDL2_ttf-2.*
	./configure && make && sudo make install
	cd ..
	cd SDL2_image-2*
	./configure && make && sudo make install
	cd ..
	cd SDL2_mixer-2*
	./configure && make && sudo make install
	cd ..

	sudo ldconfig

	# Cleaning da house
	rm SDL2-2.*.zip SDL2_*.zip
}

dialog   --title     "[ Install SDL2 version 2.0.3 ]" \
         --yes-label "Binary (Recommended)" \
         --no-label  "Compile SDL2+ttf+image+mixer" \
         --yesno     "Choose wisely:" 7 55

retval=$?

case $retval in
  0)   Install_BIN_RPi ;;
  1)   Compile_SDL_RPi ;;
esac


read -p "Done!. Press [Enter] to continue..."
