#!/bin/bash
#
# Description : Crispy-Doom ver. 5.8.0 to play DOOM & Heretic
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.6.0 (29/Jul/20)
# Compatible  : Raspberry Pi 4 (tested)
#
# HELP        : To compile crispy-doom, follow the instructions at https://github.com/fabiangreffrath/crispy-doom
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

WAD_PATH="$HOME/games"
PACKAGES=(timidity libsdl2-net-2.0-0 libsdl2-net-dev libsdl2-mixer-2.0-0)
PACKAGES_DEV=(build-essential automake git timidity libsdl2-net-2.0-0 libsdl2-net-dev libsdl2-mixer-dev)
URL_DOOM="https://www.dropbox.com/s/jy2q3f56qtl3tmu/dc.zip?dl=0"
URL_HERETIC="https://www.dropbox.com/s/bwnx5707ya6g05w/hc.zip?dl=0"
URL_HEXEN="https://www.dropbox.com/s/zj127jifcxdq7fa/hec.zip?dl=0"
URL_STRIFE="https://www.dropbox.com/s/nb6ofa4nlt7juv5/sc.zip?dl=0"
CRISPY_DOOM="https://www.dropbox.com/s/xampebl70k9ll70/crispy_5-8.0_armhf.deb?dl=0"
CRISPY_DOOM_SOURCE="https://github.com/fabiangreffrath/crispy-doom.git"
# CHOCOLATE_DOOM="https://www.dropbox.com/s/qxxrx6clyrc0e4n/chocolate_3-0_armhf.deb?dl=0" # Future release?
LICENSE="Complete"
IS_DOOM_INSTALLED=0
IS_HERETIC_INSTALLED=0

runme() {
	if [ -e /usr/bin/doom ]; then
		read -p "Do you want to play Doom right now (y/N)? " response
		if [[ $response =~ [Yy] ]]; then
			doom
		fi
	else
		if [ -e /usr/bin/heretic ]; then
			read -p "Do you want to play Heretic right now (y/N)? " response
			if [[ $response =~ [Yy] ]]; then
				heretic
			fi
		fi
	fi
	exit_message
}

removeUnusedLinks() {
	rm -f ~/.local/share/applications/crispy-hexen.desktop ~/.local/share/applications/crispy-strife.desktop
	rm -f /usr/local/share/applications/io.github.fabiangreffrath.Doom.desktop /usr/local/share/applications/io.github.fabiangreffrath.Heretic.desktop /usr/local/share/applications/io.github.fabiangreffrath.Setup.desktop
	if [[ $IS_DOOM_INSTALLED -eq 0 ]]; then
		rm -f ~/.local/share/applications/crispy-doom.desktop
	fi
	if [[ $IS_HERETIC_INSTALLED -eq 0 ]]; then
		rm -f ~/.local/share/applications/crispy-heretic.desktop
	fi
}

remove_files() {
	rm -rf "$WAD_PATH"/wads
	rm -f ~/.local/share/applications/crispy-doom.desktop ~/.local/share/applications/crispy-heretic.desktop
	sudo rm -rf /usr/bin/doom /usr/bin/heretic
}

uninstall() {
	read -p "Do you want to uninstall Crispy Doom (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		sudo apt remove -y crispy
		remove_files
		if [[ -e "$INSTALL_DIR"/arx ]]; then
			echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
			exit_message
		fi
		echo -e "\nSuccessfully uninstalled."
		exit_message
	fi
	runme
}

if [ -e "/usr/local/bin/crispy-doom" ]; then
	echo -e "Crispy-Doom already installed!."
	uninstall
	exit 1
fi

share_version() {
	URL_DOOM="https://www.dropbox.com/s/5ms8k3mpcu64jgd/ds.zip?dl=0"
	URL_HERETIC="https://www.dropbox.com/s/gkv4ulnonoghtgl/hs.zip?dl=0"
	URL_HEXEN="https://www.dropbox.com/s/mcy16sljsw14d6d/hes.zip?dl=0"
	URL_STRIFE="https://www.dropbox.com/s/z90da1azq2uhstp/ss.zip?dl=0"
}

compile() {
	installPackagesIfMissing "${PACKAGES_DEV[@]}"
	cd "$WAD_PATH"
	git clone "$CRISPY_DOOM_SOURCE" crispy-doom && cd "$_"
	sudo apt build-dep crispy-doom
	autoreconf -fiv
	./configure
	echo -e "\nCompiling...\n"
	make -j"$(getconf _NPROCESSORS_ONLN)"
	echo -e "\nDone! . Go to $(pwd) to run the binaries or type make install to install the app.\n"
}

install() {
	[ ! -d "$HOME"/games ] && mkdir -p "$HOME"/games
	installPackagesIfMissing "${PACKAGES[@]}"
	wget -O "$HOME"/crispy-doom.deb "$CRISPY_DOOM"
	sudo dpkg -i "$HOME"/crispy-doom.deb
	rm "$HOME"/crispy-doom.deb
	wget -P ~/.local/share/applications https://misapuntesde.com/res/crispy_modified_link.zip && unzip -q -o ~/.local/share/applications/crispy_modified_link.zip -d ~/.local/share/applications && rm ~/.local/share/applications/crispy_modified_link.zip
}

menu() {
	clear
	echo
	read -p "Do you have an original copy of Doom/Heretic (If not, a Shareware version will be installed) (Y/n)?: " response
	if [[ $response =~ [Nn] ]]; then
		share_version
		LICENSE="Shareware"
	fi

	if [[ $LICENSE = "Complete" ]]; then
		message_magic_air_copy
	fi

	cmd=(dialog --separate-output --title "[ Crispy-Doom. WADs License: $LICENSE ]" --checklist "Move with the arrows up & down. Space to select the game(s) you want to install" 13 120 16)
	options=(
		Doom "Space marine operating under the UAC (Union Aerospace Corporation), who fights hordes of demons" on
		Heretic "Player must first fight through the undead hordes infesting the site" off
		#  Hexen "It is the sequel to 1994's Heretic" off
		#  Strife "The game is set in a world where a dark religion called The Order has taken over" off
	)
	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

	for choice in $choices; do
		case $choice in
		Doom)
			clear
			download_and_extract "$URL_DOOM" "$WAD_PATH"
			sudo sh -c "echo 'crispy-doom -iwad $WAD_PATH/wads/DOOM.WAD' > /usr/bin/doom" && sudo chmod +x /usr/bin/doom
			IS_DOOM_INSTALLED=1
			;;
		Heretic)
			clear
			download_and_extract "$URL_HERETIC" "$WAD_PATH"
			sudo sh -c "echo 'crispy-heretic -iwad $WAD_PATH/wads/HERETIC.WAD' > /usr/bin/heretic" && sudo chmod +x /usr/bin/heretic
			IS_HERETIC_INSTALLED=1
			;;
		Hexen)
			clear
			download_and_extract "$URL_HEXEN" "$WAD_PATH"
			sudo sh -c "echo 'crispy-hexen -iwad $WAD_PATH/wads/HEXEN.WAD' > /usr/bin/hexen" && sudo chmod +x /usr/bin/hexen
			;;
		Strife)
			clear
			download_and_extract "$URL_STRIFE" "$WAD_PATH"
			sudo sh -c "echo 'crispy-strife -iwad $WAD_PATH/wads/STRIFE.WAD' > /usr/bin/strife" && sudo chmod +x /usr/bin/strife
			;;
		esac
	done
}

install
menu
removeUnusedLinks

echo -e "Installed. To play, just type doom, heretic or Go to Menu > Games.\n"
runme
echo
read -p "Press [Enter] to go back to the menu..."
