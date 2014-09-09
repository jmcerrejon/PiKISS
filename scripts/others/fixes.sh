#!/bin/bash -x
#
# Description : Fix some problems with the Raspbian OS
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.1 (9/Sep/14)
#
clear

tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
wHEIGHT=10
wWIDTH=90

trap "rm -f $tempfile" 0 1 2 5 15

SOUND(){
	sudo sed -i 's/pcm.front cards.pcm.front/pcm.front cards.pcm.default/g' /usr/share/alsa/alsa.conf
}

while true
do
	dialog --clear   \
		--title		"[ Raspbian Fixes ]" \
		--menu 		"Fix some problems with the Raspbian OS. Choose your fix or Exit:" $wHEIGHT 90 $wHEIGHT \
		Sound		"ALSA lib pcm.c:2217:(snd_pcm_open_noupdate) Unknown PCM cards.pcm.front" \
		Exit 		"Exit to the shell" 2>"${tempfile}"

	case $(<"${tempfile}") in
		Sound)	SOUND ;;
		Exit)	exit ;;
	esac
done

