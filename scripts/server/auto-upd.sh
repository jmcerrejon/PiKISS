#!/bin/bash
#
# Description : keep Debian patched with latest security updates automatically
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (21/Jul/2017)
#
# HELP		  : https://www.cyberciti.biz/faq/how-to-keep-debian-linux-patched-with-latest-security-updates-automatically/
#
clear
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

sudo apt install -y unattended-upgrades apt-listchanges bsd-mailx
# file /etc/apt/apt.conf.d/50unattended-upgrades
#      "o=Raspbian,n=jessie";
#      "o=Raspbian,a=stable";

file_backup /etc/apt/apt.conf.d/50unattended-upgrades

sudo sed -i 's/\/\/      "o=Raspbian,n=jessie";/      "o=Raspbian,n=jessie";/ig' /etc/apt/apt.conf.d/50unattended-upgrades
sudo sed -i 's/\/\/Unattended-Upgrade::Mail "root";/Unattended-Upgrade::Mail "pi";/ig' /etc/apt/apt.conf.d/50unattended-upgrades

sudo dpkg-reconfigure -plow unattended-upgrades -u

# Ask for mail
OUTPUT="/tmp/input.txt"
touch $OUTPUT
trap 'rm "${OUTPUT}"; exit' SIGHUP SIGINT SIGTERM

dialog --inputbox "Enter your e-mail:" 8 40 2>"${OUTPUT}"
respose=$?

case $respose in
  0) sudo sed -i "s/email_address=root/email_address=$(<$OUTPUT)/ig" /etc/apt/listchanges.conf ;;
  1 | 255) echo "Cancelled." ;;
esac

rm "$OUTPUT"

read -p "Done!. Press [Enter] to continue..."
