#!/bin/bash
#
# Description : Update bootloader
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.0 (11/Nov/23)
#
# Help        : https://gist.github.com/atomicstack/9c43e452c4b7cefb37c1e78f65b0b1fa
#             : https://jamesachambers.com/raspberry-pi-4-usb-boot-config-guide-for-ssd-flash-drives/
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ../helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }
clear

readonly RELEASE_NOTES_URL="https://github.com/raspberrypi/rpi-eeprom/blob/master/releases.md"
readonly FIRMWARE_BOOT_FILES_URL="https://github.com/raspberrypi/firmware/tree/master/boot"
readonly RPI_MIN_VERSION_SUPPORTED=4
readonly RPI_NUMBER=$(get_raspberry_pi_model_number)
CURRENT_BOOT_DATETIME="$(vcgencmd bootloader_version | head -n 1)"
FILE=""

if [[ $RPI_MIN_VERSION_SUPPORTED -gt $RPI_NUMBER ]]; then
    echo "Sorry. This SBC is not a Raspberry Pi 4. Aborting..."
    exit_message
fi

pick_file() {
    local RPI_4_SOCK="2711"
    local RPI_5_SOCK="2712"
    local CURRENT_SOCK

    if [[ $RPI_MIN_VERSION_SUPPORTED -eq $RPI_4_SOCK ]]; then
        CURRENT_SOCK=$RPI_4_SOCK
    else
        CURRENT_SOCK=$RPI_5_SOCK
    fi

    echo "
· Remember: Your current bootloader datetime is: $CURRENT_BOOT_DATETIME
· Choose the latest bootloader file in the next dialog.
· Use TAB to move between window sections and SPACE to select the file.
"
    read -p "Press [ENTER] to choose the file..."
    FILE=$(dialog --title "Choose a file" --stdout --title " Please choose a file to use " --fselect /lib/firmware/raspberrypi/bootloader-${CURRENT_SOCK}/stable/ 14 65)

    if [[ ! -f $FILE ]]; then
        echo "$FILE is not a valid file. Aborting."
        exit_message
    fi
}

install() {
    # Upgrade your distro
    upgrade

    # change your firmware preference to stable
    echo -e "\nChanging firmware to stable if proceed..."
    sudo sed -i 's/critical/stable/g' /etc/default/rpi-eeprom-update
    echo -e "Done."

    pick_file

    clear
    echo -e "Using the file $FILE to upgrade the bootloader."
    read -p "Do you want to continue with the process (Y/n)? " response
    if [[ $response =~ [Nn] ]]; then
        exit_message
    fi

    echo -e "\nRunning rpi-eeprom-update\n"
    sudo rpi-eeprom-update -d -f "$FILE"

    echo -e "\nCheck your SATA bridge...\n"
    sudo lsusb
    echo -e "\nIf you reboot and get a black screen beyond 1 minute, edit /boot/cmdline.txt and add at the beginning usb-storage.quirks=XXXX:XXXX:u"
    echo -e "where XXXX:XXXX is your Device ID"

    # reboot your Pi
    cmd_reboot
}

install_script_message
echo "
Install bootloader EEPROM for Raspberry Pi $RPI_NUMBER
============================================

 · Your current boot datetime is: $CURRENT_BOOT_DATETIME
 · Check out the release notes here: $RELEASE_NOTES_URL
"
read -p "Do you want to update your bootloader files (y/N)? " response
if [[ $response =~ [Yy] ]]; then
    install
fi
