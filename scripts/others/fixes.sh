#!/bin/bash
#
# Description : Fix some problems with the Raspbian OS
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.6 (18/Jan/2024)
# Tested      : Not nested.
#
# shellcheck source=../helper.sh
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

tempfile=$(mktemp) || tempfile=/tmp/test$$
wHEIGHT=14
wWIDTH=90

trap "rm -f $tempfile" 0 1 2 15

sound() {
	sudo sed -i 's/pcm.front cards.pcm.front/pcm.front cards.pcm.default/g' /usr/share/alsa/alsa.conf
}

black_screen() {
	sudo sh -c "TERM=linux setterm -foreground black -clear >/dev/tty0"
}

pgpkey() {
	if [[ -e /etc/apt/trusted.gpg.d/raspbian.gpg ]]; then
		echo -e "\nFile /etc/apt/trusted.gpg.d/raspbian.gpg already exists."
		exit_message
	fi
	echo -e "\nDownloading raspbian.public.key..."
	curl http://raspbian.raspberrypi.com/raspbian.public.key | gpg --dearmor > raspbian.gpg
	sudo mv raspbian.gpg /etc/apt/trusted.gpg.d/
	sudo apt update
	echo -e "\nDone!. Now you can install packages with apt."
}

usb_poll() {
	sudo sh -c "printf \"$(cat /boot/cmdline.txt) usbhid.mousepoll=0\" > /boot/cmdline.txt"
}

while true; do
	dialog --clear \
		--title "[ Raspbian Fixes ]" \
		--menu "Fix some problems with the Raspbian OS. Choose your fix or Exit:" $wHEIGHT 90 $wHEIGHT \
		Sound "ALSA lib pcm.c:2217:(snd_pcm_open_noupdate) Unknown PCM cards.pcm.front" \
		Black "Black out the local terminal (ideal for omxplayer)" \
		PGPKEY "Fix message Key is stored in legacy trusted.gpg keyring" \
		SDL "Fix SDL1.2 black screen" \
		USB "Fix USB HID poll rate" \
		Exit "Exit to the shell" 2>"${tempfile}"

	case $(<"${tempfile}") in
	Sound) sound ;;
	Black) black_screen ;;
	PGPKEY) PGPKEY ;;
	SDL) SDL_fix_Rpi ;;
	USB) usb_poll ;;
	Exit) exit ;;
	esac
done

exit_message