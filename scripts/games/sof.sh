#!/bin/bash
#
# Description : Soldier of Fortune
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (08/Oct/20)
# Compatible  : Raspberry Pi 4 (tested)
# Repository  : 
# Help		  : https://archive.org/download/aldude3_hotmail_Sof/sof.iso
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=()
readonly PACKAGES_DEV=()
readonly BINARY_URL=""
readonly SOURCE_CODE_URL=""
readonly INPUT=/tmp/temp.$$

runme() {
    if [ ! -f "$INSTALL_DIR"/MY_APP ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/MY_APP && ./MY_APP
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/MY_APP ~/.local/share/applications/MY_APP.desktop
}

uninstall() {
    read -p "Do you want to uninstall APP_NAME (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/MY_APP ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/MY_APP ]]; then
    echo -e "APP_NAME already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/MY_APP.desktop ]]; then
        cat <<EOF >~/.local/share/applications/MY_APP.desktop
[Desktop Entry]
Name=APP_NAME
Version=1.0
Type=Application
Comment=
Exec=${INSTALL_DIR}/MY_APP/MY_APP
Icon=${INSTALL_DIR}/MY_APP/logo.png
Path=${INSTALL_DIR}/MY_APP/
Terminal=false
Categories=Game;
EOF
    fi
}

end_message() {
    echo -e "\n\nDone!. You can play typing $INSTALL_DIR/MY_APP/MY_APP or opening the Menu > Games > APP_NAME.\n"
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_"
    git clone "$GITHUB_URL" MY_APP && cd "$_"
    # Do the Mario!...
    make_with_all_cores "\nCompiling..."
    read -p "Do you want to install globally the app (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo make install
    fi
    echo -e "\nDone!. Check the code at $HOME/sc/MY_APP."
    exit_message
}

download_binaries() {
    echo -e "\nInstalling binary files..."
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    download_binaries
    generate_icon
    echo
    read -p "Do you have data files set on the file res/magic-air-copy-pikiss.txt for APP_NAME (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        download_data_files "$INSTALL_DIR/MY_APP"
        end_message
        runme
    fi

    echo -e "\nCopy the data files inside $INSTALL_DIR/MY_APP/UFO."
    end_message
    exit_message
}

menu() {
    while true; do
        dialog --clear \
            --title "[ MY_APP ]" \
            --menu "Select from the list:" 11 70 3 \
            INSTALL "Binary (Recommended)" \
            COMPILE "Latest from source code." \
            Exit "Exit" 2>"${INPUT}"

        menuitem=$(<"${INPUT}")

        case $menuitem in
        INSTALL) clear && install ;;
        COMPILE) clear && compile ;;
        Exit) exit ;;
        esac
    done
}

menu
