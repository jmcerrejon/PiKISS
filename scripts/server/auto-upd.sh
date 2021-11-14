#!/bin/bash
#
# Description : keep Debian patched with latest security updates automatically
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.0 (11/Nov/2021)
#
# HELP		  : https://www.cyberciti.biz/faq/how-to-keep-debian-linux-patched-with-latest-security-updates-automatically/
#
clear
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

CODENAME=$(get_codename)
PACKAGES=(unattended-upgrades apt-listchanges bsd-mailx)

install() {
    echo -e "\nInstalling..."
    install_packages_if_missing "${PACKAGES[@]}"
    file_backup /etc/apt/apt.conf.d/50unattended-upgrades

    sudo sed -i 's/\/\/      "o=Raspbian,n=$CODENAME";/      "o=Raspbian,n=$CODENAME";/ig' /etc/apt/apt.conf.d/50unattended-upgrades
    sudo sed -i 's/\/\/Unattended-Upgrade::Mail "root";/Unattended-Upgrade::Mail "pi";/ig' /etc/apt/apt.conf.d/50unattended-upgrades

    sudo dpkg-reconfigure -plow unattended-upgrades -u

    # Ask for mail
    OUTPUT="/tmp/input.txt"
    touch $OUTPUT
    trap 'rm "${OUTPUT}"; exit' SIGHUP SIGINT SIGTERM

    dialog --inputbox "Enter your E-mail:" 8 40 2>"${OUTPUT}"
    respose=$?

    case $respose in
    0) sudo sed -i "s/email_address=root/email_address=$(<$OUTPUT)/ig" /etc/apt/listchanges.conf ;;
    1 | 255) echo "Cancelled." ;;
    esac

    rm "$OUTPUT"
    exit_message
}

install_script_message
install
