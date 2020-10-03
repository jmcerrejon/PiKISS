#!/bin/bash
#
# Description : Box86
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.1 (03/Oct/20)
# Compatible  : Raspberry Pi 2-4 (tested)
# Repository  : https://github.com/ptitSeb/box86
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/box86"
readonly PACKAGES_DEV=( cmake )
readonly SOURCE_PATH="https://github.com/ptitSeb/box86.git"
readonly INPUT=/tmp/box86.$$

end_message() {
    echo -e "\nDone!. box86 installed on system. Just type box86 <binary_app>"
    exit_message
}

install() {
    installBox86
    cd "$INSTALL_DIR"/build
    sudo make install
    end_message
}

compile() {
    local PI_VERSION_NUMBER
    PI_VERSION_NUMBER=$(getRaspberryPiNumberModel)

    echo -e "Compiling, please wait...\n"
    installPackagesIfMissing "${PACKAGES_DEV[@]}"
    cd
    if [ ! -d "$INSTALL_DIR" ]; then
        git clone "$SOURCE_PATH" box86
    fi
    cd ~/box86
    mkdir -p build && cd "$_"
    cmake .. -DRPI${PI_VERSION_NUMBER}=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo
    make_with_all_cores
    sudo make install
    end_message
}

menu() {
     while true; do
        dialog --clear \
            --title "[ Box86 for Raspberry Pi 2-4 ]" \
            --menu "Choose language:" 11 80 3 \
            Binary "Install the binary for Raspberry Pi 4 (03/Oct/20)" \
            Source "Compile sources for Raspberry Pi 2-4. Est. time RPi 4: ~5 min." \
            Exit "Return to main menu" 2>"${INPUT}"

        menuitem=$(<"${INPUT}")

        case $menuitem in
        Binary) clear && install && return 0 ;;
        Source) clear && compile && return 0 ;;
        Exit) exit 0 ;;
        esac
    done
}

if [[ -d "$INSTALL_DIR" ]]; then
    read -p "Box86 already installed. Do you want to update it (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR"/build "$INSTALL_DIR"/box86
        compile
    else
        exit_message
    fi
fi

menu
