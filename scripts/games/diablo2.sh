#!/bin/bash
#
# Description : Diablo 2 Exp. Spanish for Raspberry Pi
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.5 (25/Oct/20)
# Compatible  : Raspberry Pi 4 (tested)
#
# Info		  : Thks to PI Labs and Notaz
# Help		  : xrandr --newmode "800x600_60.00"  38.25  800 832 912 1024 600 603 607 624 -hsync +vsync or xrandr --newmode HDMI-1 800x600_60.00
#

. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly SCRIPT_PATH="$HOME/games/diablo2/diablo2.sh"
readonly BINARY_PATH="https://notaz.gp2x.de/misc/starec/libd2game_sa_arm.exe.so.xz"
readonly VAR_DATA_NAME_EN="DIABLO2_EN"
readonly VAR_DATA_NAME_ES="DIABLO2_ES"
readonly PIKISS_PATH=$(pwd)
INPUT=/tmp/diablo2.$$
DATA_URL=""

remove_files() {
    rm -rf "$INSTALL_DIR"/diablo2 ~/.local/share/applications/diablo2.desktop
}

uninstall() {
    read -p "Do you want to uninstall Diablo 2 (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/diablo2 ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled. NOTE: You need to uninstall wine manually with sudo apt remove -y wine"
        exit_message
    fi
    exit_message
}

generate_icon() {
    echo -e "\nGenerating icon..."
    cp -f "$PIKISS_PATH"/res/diabloII.png "$INSTALL_DIR"/diablo2/diabloII.png
    if [[ ! -e ~/.local/share/applications/diablo2.desktop ]]; then
        cat <<EOF >~/.local/share/applications/diablo2.desktop
[Desktop Entry]
Name=Diablo 2 Lord of Destruction
Exec=/home/pi/games/diablo2/diablo2.sh
Icon=/home/pi/games/diablo2/diabloII.png
Type=Application
Comment=Set in the fictional Kingdom of Khanduras in the mortal realm, Diablo makes the player take control of a lone hero battling to rid the world of Diablo
Categories=Game;ActionGame;
EOF
    fi
}

copy_run_script() {
    mkdir -p "$INSTALL_DIR"/diablo2
    cp -f "$PIKISS_PATH"/res/diablo2.sh "$SCRIPT_PATH"
}

install_dependencies() {
    echo -e "\nInstalling dependencies (if proceed)...\n"
    if ! isPackageInstalled wine; then
        sudo apt install -y wine
    fi
}

download_binaries() {
    echo -e "\nInstalling binary files..."
    download_and_extract "$BINARY_PATH" "$INSTALL_DIR"/diablo2
}

end_message() {
    winecfg >/dev/null &
    echo -e "\nOn winecfg, go to Graphics Tab and set Emulate a virtual desktop to 800x600. Then, run $SCRIPT_PATH or click on Menu > Games > Diablo 2 Lord of Destruction."
    exit_message
}

download_data_files() {
    if ! message_magic_air_copy "$DATA_URL"; then
        echo -e "\nNow copy data directory into $INSTALL_DIR/diablo2."
        end_message
        return 0
    fi
    mkdir -p "$INSTALL_DIR" && cd "$_"
    download_and_extract "$DATA_URL" "$INSTALL_DIR"
    end_message
}

choose_data_files() {
    while true; do
        dialog --clear \
            --title "[ Diablo 2 Data files ]" \
            --menu "Choose language:" 11 68 3 \
            English "Install the game with English text and voices." \
            Spanish "Install the game with Spanish text and voices." \
            Exit "Exit" 2>"${INPUT}"

        menuitem=$(<"${INPUT}")

        case $menuitem in
        English) clear && DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME_EN") && download_data_files ;;
        Spanish) clear && DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME_ES") && download_data_files ;;
        Exit) remove_files && clear && exit_message ;;
        esac
    done
}

install() {
    mkdir -p "$INSTALL_DIR"/diablo2
    install_dependencies
    installMesa
    copy_run_script
    generate_icon
    echo
    read -p "Do you have data files set on the file res/magic-air-copy-pikiss.txt for Diablo 2 (Y/n)? " response
    if [[ $response =~ [Nn] ]]; then
        download_binaries
        echo -e "\nDone. Please, copy Diablo2 file games inside $INSTALL_DIR/diablo2"
        end_message
    fi

    choose_data_files
}

if [ -f "/usr/local/bin/twistver" ]; then
    echo "It's not recommended to install Diablo II on Twister OS at this time due to conflicts with x86 wine."
    exit_message
fi

if [[ -d "$INSTALL_DIR"/diablo2 ]]; then
    echo -e "Diablo 2 already installed.\n"
    uninstall
    exit 1
fi

install_script_message
echo "Install Diablo 2 thks to Notaz
==============================
 · Languages: English, Spanish.
 · Install path: $INSTALL_DIR/diablo2
 · NOTE: Only runs on Raspberry Pi 4
"

read -p "Press [Enter] to continue..."

install
