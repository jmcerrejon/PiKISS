#!/bin/bash -x
#
# Description : Fix some problems with the Raspbian OS
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.4 (5/Apr/15)
# Compatible  : Raspberry Pi 1 (Doesn't work) & 2 (tested. OK.)
#
clear

. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
wHEIGHT=10
wWIDTH=90

trap "rm -f $tempfile" 0 1 2 5 15

SOUND(){
	sudo sed -i 's/pcm.front cards.pcm.front/pcm.front cards.pcm.default/g' /usr/share/alsa/alsa.conf
}

BLACK_SCREEN(){
	sudo sh -c "TERM=linux setterm -foreground black -clear >/dev/tty0"
}

while true
do
	dialog --clear   \
		--title		"[ Raspbian Fixes ]" \
		--menu 		"Fix some problems with the Raspbian OS. Choose your fix or Exit:" $wHEIGHT 90 $wHEIGHT \
		Sound		"ALSA lib pcm.c:2217:(snd_pcm_open_noupdate) Unknown PCM cards.pcm.front" \
		Black		"Black out the local terminal (ideal for omxplayer)" \
		SDL		"Fix SDL1.2 black screen" \
		Exit 		"Exit to the shell" 2>"${tempfile}"

	case $(<"${tempfile}") in
		Sound)	SOUND ;;
		Black)	BLACK_SCREEN ;;
		SDL)	SDL_fix_Rpi ;;
		Exit)	exit ;;
	esac
done

