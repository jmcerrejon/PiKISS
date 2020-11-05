#!/bin/bash
#
# Description : Box86
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.5 (05/Nov/20)
# Compatible  : Raspberry Pi 2-4 (tested)
# Repository  : https://github.com/ptitSeb/box86
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INPUT=/tmp/box86.$$

uninstall_box86() {
    if [[ ! -f /usr/local/bin/box86 ]]; then
        echo -e "\nNothing to uninstall."
        return 0
    fi

    echo -e "\nUninstalling..."
    sudo rm -rf ~/box86 /usr/local/bin/box86 /etc/binfmt.d/box86.conf /usr/lib/i386-linux-gnu/libstdc++.so.6 /usr/lib/i386-linux-gnu/libstdc++.so.5 /usr/lib/i386-linux-gnu/libgcc_s.so.1
    echo -e "Done."
}

menu() {
     while true; do
        dialog --clear \
            --title "[ Box86 for Raspberry Pi 2-4 ]" \
            --menu "Choose language:" 11 80 3 \
            Binary "Install the binary for Raspberry Pi 4 (05/Nov/20)" \
            Source "Compile sources for Raspberry Pi 2-4. Est. time RPi 4: ~5 min." \
            Uninstall "Uninstall Box86 from your system." \
            Exit "Return to main menu" 2>"${INPUT}"

        menuitem=$(<"${INPUT}")

        case $menuitem in
        Binary) clear && install_box86 && return 0 ;;
        Source) clear && compile_box86 && return 0 ;;
        Uninstall) clear && uninstall_box86 && return 0 ;;
        Exit) exit 0 ;;
        esac
    done
}

menu
exit_message
