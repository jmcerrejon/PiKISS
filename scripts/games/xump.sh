#!/bin/bash
#
# Description : Xump
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.1 (23/Jul/20)
# Compatible  : Raspberry Pi 1-4 (tested)
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="/home/$USER/games/xump/"
URL_FILE="https://www.retroguru.com/xump/xump-v.latest-raspberrypi.zip"

if which "$INSTALL_DIR"/xump_rpi >/dev/null; then
	read -p "Warning!: Xump already installed. Press [ENTER] to exit..."
	exit
fi

validate_url() {
	if [[ $(wget -S --spider $1 2>&1 | grep 'HTTP/1.1 200 OK') ]]; then echo "true"; fi
}

generateIcon() {
	if [[ ! -e ~/.local/share/applications/Xump.desktop ]]; then
		cat <<EOF >~/.local/share/applications/Xump.desktop
[Desktop Entry]
Name=Xump
Exec=/home/pi/games/xump/xump_rpi
Icon=terminal
Type=Application
Comment=Xump - The Final Run is a simple multi-platform puzzler by Retroguru
Categories=Game;ActionGame;
Path=/home/pi/games/xump/
EOF
	fi
}

install() {
	if [[ $(validate_url $URL_FILE) != "true" ]]; then
		read -p "Sorry, the game is not available here: $URL_FILE. Visit the website to download it manually."
		exit_message
	fi

	sudo apt install -y libsdl-mixer1.2

	mkdir -p "$INSTALL_DIR" && cd "$_"
	wget -O /tmp/xump.zip $URL_FILE && unzip -o /tmp/xump.zip -d "$INSTALL_DIR" && rm /tmp/xump.zip
	chmod +x xump_rpi
	echo "Generating icon..."
	generateIcon
	echo -e "Done!. To play, on Desktop go to Menu > Games or via terminal, go to $INSTALL_DIR and type: ./xump_rpi\n\nEnjoy!"
	
	exit_message
}

echo "Install Xump (Raspberry Pi version)"
echo "==================================="
echo -e "More Info: https://www.retroguru.com/xump/\n\nInstall path: $INSTALL_DIR"
while true; do
	echo " "
	read -p "Proceed? [y/n] " yn
	case $yn in
		[Yy]*) echo "Installing, please wait..." && install ;;
		[Nn]*) exit ;;
		[Ee]*) exit ;;
		*) echo "Please answer (y)es, (n)o or (e)xit." ;;
	esac
done
