#!/bin/bash
#
# Description : Compile SDL 2.0.12
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.4.0 (22/Jul/20)
#
# Help        : https://github.com/jlnr/gosu/wiki/Getting-Started-on-Raspbian-%28Raspberry-Pi%29
# 	          : https://hg.libsdl.org/SDL/file/default/build-scripts/raspberrypi-buildbot.sh
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

SDL2_DBG_PKG_URL="https://malus.exotica.org.uk/~buzz/pi/sdl/sdl2/libsdl2-dbg_2.0.12_armhf.deb"
SDL2_DEV_PKG_URL="http://ftp.br.debian.org/debian/pool/main/libs/libsdl2/libsdl2-dev_2.0.12+dfsg1-1_armhf.deb"
SDL2_PKG_URL="http://ftp.br.debian.org/debian/pool/main/libs/libsdl2/libsdl2-2.0-0_2.0.12+dfsg1-1_armhf.deb"
SDL2_SC_URL="https://www.libsdl.org/release/SDL2-2.0.12.zip"
SDL2_TTF_SC_URL="https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-2.0.15.zip"
SDL2_IMAGE_SC_URL="https://www.libsdl.org/projects/SDL_image/release/SDL2_image-2.0.5.zip"
SDL2_MIXER_SC_URL="https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-2.0.4.zip"
SDL2_ALT_URL="https://buildbot.libsdl.org/sdl-builds/sdl-raspberrypi/sdl-raspberrypi-114.tar.xz"

Install_BIN_RPi1() {
	clear
	echo -e "\nInstalling SDL 2.0.13..."
	wget -q -O /tmp/sdl2.tar.xz "$SDL2_ALT_URL"
	echo "Extracting..."
	cd /tmp && extract /tmp/sdl2.tar.xz
	echo "Moving..."
	sudo rsync -a --remove-source-files /tmp/usr /
	rm -rf /tmp/usr
	ldconfig_and_show_version
}

Install_BIN_RPi2() {
	clear
	echo -e "\nDownloading 2.0.12..."
	wget -P "$HOME" "$SDL2_DBG_PKG_URL"
	wget -P "$HOME" "$SDL2_DEV_PKG_URL"
	wget -P "$HOME" "$SDL2_PKG_URL"
	echo -e "\nInstalling SDL..."
	sudo dpkg -i "$HOME"/libsdl2*.deb
	rm -f "$HOME"/"$(basename $SDL2_DBG_PKG_URL)" "$HOME"/"$(basename $SDL2_DEV_PKG_URL)" "$HOME"/"$(basename $SDL2_PKG_URL)"
	ldconfig_and_show_version
}

ldconfig_and_show_version() {
	local VERSION
	VERSION="$(sdl2-config --version)"
	sudo ldconfig
	echo
	echo "Version installed: $VERSION"
	echo -e "\nDone!."
}

Compile_SDL_RPi() {
	clear
	local INSTALL_GLOBALLY_AFTER_COMPILE=1
	local CORES
	CORES=$(nproc --all)

	echo -e "Compile SDL 2.0.12 + ttf + image + mixer\n======================================\nIt can takes On Rpi 4 ~15 min. Be patience...\n"

	read -p "Do you want to install globally each library after compilation (Y/n)? " response
	if [[ $response =~ [Nn] ]]; then
		INSTALL_GLOBALLY_AFTER_COMPILE=0
	fi

	sudo apt-get install -y libasound2-dev libudev-dev libibus-1.0-dev libdbus-1-dev fcitx-libs-dev libsndio-dev libx11-dev libxcursor-dev \
		libxext-dev libxi-dev libxinerama-dev libxkbcommon-dev libxrandr-dev libxss-dev libxt-dev libxv-dev libxxf86vm-dev libegl1-mesa-dev \
		libgles2-mesa-dev libgl1-mesa-dev libglu1-mesa-dev libdrm-dev libgbm-dev libfontconfig1-dev qt5-default automake mercurial libtool \
		libfreeimage-dev libopenal-dev libpango1.0-dev libsndfile1-dev libtiff5-dev libwebp-dev libaudio-dev freeglut3-dev libmodplug-dev \
		libsmpeg-dev libjpeg-dev libsamplerate0-dev libjack-dev libopusfile-dev libmpg123-dev libfluidsynth-dev libesd0-dev libvulkan-dev

	mkdir -p "$HOME"/sc && cd "$_"

	echo -e "\nDownloading source code...\n"
	wget -q --show-progress "$SDL2_SC_URL"
	wget -q --show-progress "$SDL2_TTF_SC_URL"
	wget -q --show-progress "$SDL2_IMAGE_SC_URL"
	wget -q --show-progress "$SDL2_MIXER_SC_URL"

	# Unzip them all!
	echo -e "\nUncompressing...\n"
	unzip -qq \*.zip

	# Cleaning da house
	rm SDL2-2.*.zip SDL2_*.zip

	cd SDL2-2.*
	./autogen.sh
	./configure --disable-video-opengl --disable-video-x11 --disable-pulseaudio --disable-esd --enable-video-opengles --enable-libudev --enable-arm-simd --host=arm-raspberry-linux-gnueabihf
	make -j"${CORES}"
	if [[ ${INSTALL_GLOBALLY_AFTER_COMPILE} -eq 1 ]]; then
		sudo make install
	fi

	cd ../SDL2_ttf-2.*
	./configure
	make -j"${CORES}"
	if [[ ${INSTALL_GLOBALLY_AFTER_COMPILE} -eq 1 ]]; then
		sudo make install
	fi
	cd ../SDL2_image-2*
	./configure
	make -j"${CORES}"
	if [[ ${INSTALL_GLOBALLY_AFTER_COMPILE} -eq 1 ]]; then
		sudo make install
	fi
	cd ../SDL2_mixer-2*
	./configure
	make -j"${CORES}"
	if [[ ${INSTALL_GLOBALLY_AFTER_COMPILE} -eq 1 ]]; then
		sudo make install
	fi
	cd ..

	ldconfig_and_show_version
}

cmd=(dialog --clear --title "[ Compile SDL2 version ]" --menu "Select an option from the list. This process can't be undone:" 11 80 50)

options=(
	METHOD_1 "Install the binaries 2.0.13 (Recommended)"
	# METHOD_2 "Install the binaries 2.0.12"
	COMPILE "Compile SDL2 + ttf + image + mixer with Vulkan support"
	EXIT "Exit from the script"
)

choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

for choice in $choices; do
	case $choice in
	METHOD_1) Install_BIN_RPi1 ;;
	METHOD_2) Install_BIN_RPi2 ;;
	COMPILE) Compile_SDL_RPi ;;
	EXIT) exit ;;
	esac
done

exit_message
