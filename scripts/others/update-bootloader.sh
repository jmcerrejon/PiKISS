#!/bin/bash
#
# Description : Update bootloader
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (04/Nov/20)
#
# Help        : https://www.jeffgeerling.com/blog/2020/im-booting-my-raspberry-pi-4-usb-ssd
#             : https://gist.github.com/atomicstack/9c43e452c4b7cefb37c1e78f65b0b1fa
#             : https://jamesachambers.com/raspberry-pi-4-usb-boot-config-guide-for-ssd-flash-drives/
#
. ./scripts/helper.sh || . ../helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }
clear

install() {
    echo -e "\nUpgrading your distro...\n"
    sudo apt-get -qq update && sudo apt-get dist-upgrade
    mkdir -p ~/bootfiles && cd "$_"

    echo -e "\nDownloading boot files...\n"
    wget $( wget -q --show-progress -O - https://github.com/raspberrypi/firmware/tree/master/boot | perl -nE 'chomp; next unless /[.](elf|dat)/; s/.*href="([^"]+)".*/$1/; s/blob/raw/; say qq{https://github.com$_}' )

    # change your firmware preference to stable
    echo -e "\nChanging firmware to stable if proceed...\n"
    sudo sed -i 's/critical/stable/g' /etc/default/rpi-eeprom-update

    # copy the .elf and .dat files to your /boot directory
    echo -e "\nCopying firmware to /boot...\n"
    sudo cp -f *.elf /boot/
    sudo cp -f *.dat /boot/

    echo -e "\nRunning rpi-eeprom-update\n"
    sudo rpi-eeprom-update

    echo -e "\nCheck what is your SATA bridge...\n"
    sudo lsusb
    echo -e "\nIf you reboot and get a black screen beyond 1 minute, edit /boot/cmdline.txt and add at the beginning usb-storage.quirks=XXXX:XXXX:u"
    echo -e "where XXXX:XXXX is your Device ID"

    [[ -d ~/bootfiles ]] && rm -rf ~/bootfiles

    # reboot your Pi
    cmd_reboot
}

install_script_message
echo
read -p "Do you want to update your bootloader files (y/N)? " response
if [[ $response =~ [Yy] ]]; then
    install
fi
