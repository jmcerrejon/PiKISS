#!/bin/bash
#
# Description : Box86
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.3 (05/Oct/20)
# Compatible  : Raspberry Pi 2-4 (tested)
# Repository  : https://github.com/ptitSeb/box86
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/box86"
readonly PACKAGES_DEV=( cmake )
readonly INPUT=/tmp/box86.$$

end_message() {
    echo -e "\nDone!. Box86 on your system!. Just type box86 <binary_app>"
    exit_message
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
        Binary) clear && install_box86 && return 0 ;;
        Source) clear && compile_box86 && return 0 ;;
        Exit) exit 0 ;;
        esac
    done
}

if [[ -f /usr/local/bin/box86 ]]; then
    read -p "Box86 already installed. Do you want to update it (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        compile_box86
    else
        exit_message
    fi
fi

menu
end_message