#!/bin/bash
#
# Description : Crispy-Doom ver. 5.8.0 to play DOOM & Heretic
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.5.2 (10/Jul/20)
# Compatible  : Raspberry Pi 4 (tested)
#
# HELP        : To compile crispy-doom, follow the instructions at https://github.com/fabiangreffrath/crispy-doom
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

WAD_PATH="$HOME/games"
URL_DOOM="https://www.dropbox.com/s/jy2q3f56qtl3tmu/dc.zip?dl=0"
URL_HERETIC="https://www.dropbox.com/s/bwnx5707ya6g05w/hc.zip?dl=0"
URL_HEXEN="https://www.dropbox.com/s/zj127jifcxdq7fa/hec.zip?dl=0"
URL_STRIFE="https://www.dropbox.com/s/nb6ofa4nlt7juv5/sc.zip?dl=0"
CRISPY_DOOM="https://www.dropbox.com/s/xampebl70k9ll70/crispy_5-8.0_armhf.deb?dl=0"
CRISPY_DOOM_SOURCE="https://github.com/fabiangreffrath/crispy-doom.git"
# CHOCOLATE_DOOM="https://www.dropbox.com/s/qxxrx6clyrc0e4n/chocolate_3-0_armhf.deb?dl=0" # Future release?
LICENSE="Complete"

playNow() {
	read -p "Do you want to play Doom right now (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		doom
	fi
}

if [ -e "/usr/local/bin/crispy-doom" ]; then
	echo -e "Crispy-Doom already installed!."
	playNow
	exit 1
fi


get_wad() {
	echo -e "\n\nDownloading WAD files...\n"
	[ ! -d "$HOME"/games ] && mkdir -p "$HOME"/games
	wget -qO- -O "$WAD_PATH"/"$1".zip "$2"
	unzip -q -o "$WAD_PATH"/"$1".zip -d "$WAD_PATH"
	rm "$WAD_PATH"/"$1".zip
}

removeUnusedLinks() {
	echo -e "\nRemoving unused menu shortcuts...\n"
	rm -f ~/.local/share/applications/crispy-hexen.desktop ~/.local/share/applications/crispy-strife.desktop
	rm -f /usr/local/share/applications/io.github.fabiangreffrath.Doom.desktop /usr/local/share/applications/io.github.fabiangreffrath.Heretic.desktop /usr/local/share/applications/io.github.fabiangreffrath.Setup.desktop
}

share_version() {
	URL_DOOM="https://www.dropbox.com/s/5ms8k3mpcu64jgd/ds.zip?dl=0"
	URL_HERETIC="https://www.dropbox.com/s/gkv4ulnonoghtgl/hs.zip?dl=0"
	URL_HEXEN="https://www.dropbox.com/s/mcy16sljsw14d6d/hes.zip?dl=0"
	URL_STRIFE="https://www.dropbox.com/s/z90da1azq2uhstp/ss.zip?dl=0"
}

compile() {
	echo -e "\nInstalling deps...\n"
	cd "$WAD_PATH"
	git clone "$CRISPY_DOOM_SOURCE" crispy-doom && cd "$_"
	sudo apt install -y build-essential automake git timidity libsdl2-net-2.0-0 libsdl2-net-dev libsdl2-mixer-dev
	sudo apt build-dep crispy-doom
	autoreconf -fiv
	./configure
	echo -e "\nCompiling...\n"
	make -j"$(getconf _NPROCESSORS_ONLN)"
	echo -e "\nDone! . Go to $(pwd) to run the binaries or type make install to install the app.\n"
}

install() {
	echo -e "\nInstalling deps...\n"
	sudo apt install -y timidity libsdl2-net-2.0-0 libsdl2-net-dev libsdl2-mixer-2.0-0
	wget -O "$HOME"/crispy-doom.deb "$CRISPY_DOOM"
	sudo dpkg -i "$HOME"/crispy-doom.deb
	rm "$HOME"/crispy-doom.deb
	wget -P ~/.local/share/applications https://misapuntesde.com/res/crispy_modified_link.zip && unzip -q -o ~/.local/share/applications/crispy_modified_link.zip -d ~/.local/share/applications && rm ~/.local/share/applications/crispy_modified_link.zip
	removeUnusedLinks
}

menu() {
	dialog --title "[ Crispy-Doom. WADs License ]" \
		--yes-label "Shareware" \
		--no-label "Complete" \
		--yesno "Choose what type of WAD files do you want to install. NOTE: For complete version, you must be the owner of the original game (in some countries)" 7 55
	retval=$?

	case $retval in
	0)
		share_version
		LICENSE="Shareware"
		;;
	255) exit ;;
	esac

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
			get_wad doom "$URL_DOOM"
			sudo sh -c "echo 'crispy-doom -iwad $WAD_PATH/wads/DOOM.WAD' > /usr/bin/doom" && sudo chmod +x /usr/bin/doom
			;;
		Heretic)
			get_wad heretic "$URL_HERETIC"
			sudo sh -c "echo 'crispy-heretic -iwad $WAD_PATH/wads/HERETIC.WAD' > /usr/bin/heretic" && sudo chmod +x /usr/bin/heretic
			;;
		Hexen)
			get_wad Hexen "$URL_HEXEN"
			sudo sh -c "echo 'crispy-hexen -iwad $WAD_PATH/wads/HEXEN.WAD' > /usr/bin/hexen" && sudo chmod +x /usr/bin/hexen
			;;
		Strife)
			get_wad Strife "$URL_STRIFE"
			sudo sh -c "echo 'crispy-strife -iwad $WAD_PATH/wads/STRIFE.WAD' > /usr/bin/strife" && sudo chmod +x /usr/bin/strife
			;;
		esac
	done
}

install
menu

echo -e "Installed. To play, just type doom, heretic or Go to Menu > Games.\n"
playNow
echo
read -p "Press [Enter] to go back to the menu..."
