#!/bin/bash
#
# Description : Fruit'Y
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.2 (20/Jun/21)
# Compatible  : NOT WORKING ON Raspberry Pi 4 (tested)
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games/"
readonly BINARY_URL="https://www.retroguru.com/fruity/fruity-v.latest-raspberrypi.zip"

if  which $INSTALL_DIR/fruity_rpi >/dev/null ; then
    read -p "Warning!: Fruit'Y already installed. Press [ENTER] to exit..."
    exit
fi

generate_icon() {
    echo "Generating icon..."
    if [[ ! -e ~/.local/share/applications/Fruity.desktop ]]; then
cat << EOF > ~/.local/share/applications/Fruity.desktop
[Desktop Entry]
Name=Fruity
Exec=${PWD}/fruity_rpi/fruity_rpi
Icon=terminal
Type=Application
Comment=Playing with edibles is heavily inspired by the Kaiko classic Gem'X
Categories=Game;ActionGame;
Path=${PWD}/fruity_rpi/
EOF
    fi
}

install() {
    mkdir -p "$INSTALL_DIR" && cd "$_" || exit 1
    download_and_extract "$BINARY_URL" "$INSTALL_DIR/fruity"
    chmod +x fruity_rpi
    generate_icon
    echo -e "Done!. To play, on Desktop go to Menu > Games or via terminal, go to $INSTALL_DIR and type: ./fruity_rpi\n\nEnjoy!"
    exit_message
}

install_script_message
echo "Install Fruit'Y (Raspberry Pi version)"
echo "======================================"
echo -e "More Info: https://www.retroguru.com/fruity/\n\nInstall path: $INSTALL_DIR"
while true; do
    echo " "
    read -p "Proceed? [y/n] " yn
    case $yn in
    [Yy]* ) echo "Installing, please wait..." && install;;
    [Nn]* ) exit;;
    [Ee]* ) exit;;
    * ) echo "Please answer (y)es, (n)o or (e)xit.";;
    esac
done
