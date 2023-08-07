#!/bin/bash
#
# Description : Capitan Sevilla El Remake (AKA Captain 'S' The Remake)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com) and Salvador (Pi Labs)
# Version     : 1.0.4 (07/Aug/23)
# Compatible  : Raspberry Pi 3-4 (tested)
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"
URL_FILE="https://misapuntesde.com/rpi_share/captain_s.tar.gz"

playNow() {
    echo
    read -p "Do you want to play Captain S right now (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        cd "$INSTALL_DIR"/captain_s && ./captain
    fi
}

uninstall() {
    read -p "Do you want to uninstall Captain S (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR"/captain_s "$HOME"/.capitan "$HOME"/.local/share/applications/capitan*
        if [[ -e "$INSTALL_DIR"/captain_s ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    playNow
}

if [[ -d "$INSTALL_DIR"/captain_s ]]; then
    echo -e "Captain S already installed.\n"
    uninstall
    exit 1
fi

generate_icon() {
    echo -e "\nGenerating icons..."
    if [[ ! -e ~/.local/share/applications/capitan.desktop ]]; then
        cat <<EOF >~/.local/share/applications/capitan.desktop
[Desktop Entry]
Encoding=UTF-8
Name=Captain 'S' The Remake
Comment=Save Seville from the evil Torrebruno
Exec=${PWD}/captain_s/captain.sh
Icon=${PWD}/captain_s/extra/icon_captain.png
Terminal=false
Type=Application
Categories=Application;Game;ArcadeGame;
StartupNotify=false
EOF
    fi

    if [[ ! -e ~/.local/share/applications/capitan-doc.desktop ]]; then
        cat <<EOF >~/.local/share/applications/capitan-doc.desktop
[Desktop Entry]
Encoding=UTF-8
Name=Captain 'S' The Documentation
Comment=Read how to save Seville from the evil Torrebruno
Exec=qpdfview ${PWD}/captain_s/extra/instructions.pdf
Icon=${PWD}/captain_s/extra/icon_captain.png
Terminal=false
Type=Application
Categories=Application;Game;ArcadeGame;
StartupNotify=false
EOF
    fi
}

install() {
    echo -e "\nInstalling...\n"
    if ! isPackageInstalled liballegro4.4; then
        sudo apt install -y liballegro4.4
    fi
    if ! isPackageInstalled libpng16-16; then
        sudo apt install -y libpng16-16
    fi
    mkdir -p "$INSTALL_DIR" && cd "$_" || exit 1
    wget -qO- -O "$INSTALL_DIR"/captain_s.tar.gz "$URL_FILE"
    tar xf captain_s.tar.gz && rm captain_s.tar.gz
    mkdir -p "$HOME/.capitan" && cp "$INSTALL_DIR/captain_s/capitan.cfg" "$HOME/.capitan"
    echo -e "Generating shorcuts menu..."
    generate_icon
    echo -e "\nDone. To play, on Desktop go to Menu > Games or via terminal, cd $INSTALL_DIR/captain_s and type: ./captain\n\nControls: Arrow: Move | CTRL: Action | ENTER: Change character when get a sausage or change superpower when you are Captain S."
    playNow
    exit_message
}

echo "Install Capitan Sevilla (AKA Captain S)"
echo -e "=======================================\n"
echo " · More Info: https://computeremuzone.com/ficha.php?id=754&l=en"
echo " · Languages: English, Spanish."
echo " · Install path: $INSTALL_DIR/captain_s"
echo " · NOTE: There is a bug: If you set a new language, you can't change it anymore (FIX: delete the folder ~/.capitan)."
echo ""
read -p "Press [Enter] to continue..."
install
