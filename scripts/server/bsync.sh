#!/bin/bash
#
# Description : Bittorrent Sync alternatives (AKA Bittorrent Sync)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.1 (25/Jul/17)
#
# HELP        · https://www.resilio.com/individuals/
#             · http://jack.minardi.org/raspberry_pi/replace-dropbox-with-bittorrent-sync-and-a-raspberry-pi/
#
clear

IP=$(get_ip)
tempfile=$(mktemp)

install_resilio() {
  echo "deb http://linux-packages.resilio.com/resilio-sync/deb resilio-sync non-free" | sudo tee /etc/apt/sources.list.d/resilio-sync.list
  wget -qO - https://linux-packages.resilio.com/resilio-sync/key.asc | sudo apt-key add -
  sudo dpkg --add-architecture armhf
  sudo apt-get update
  sudo apt-get install resilio-sync
  sudo apt install -y resilio-sync
  sudo systemctl enable resilio-sync
  echo -e "Done!. Now reboot and go to another device/PC and type in your Web browser: http://${IP}:8888/gui/"
  read -p 'Press [ENTER] to continue...'
}

while true
do
  dialog --backtitle "PiKISS" --title "[ Install Bittorrent Sync ]" --clear --menu  "Pick one:" 15 55 6 \
  Resilio  "Resilio Sync Home (Latest)" \
  Syncthing  "Syncthing" \
  Exit   "Exit" 2>"${tempfile}"

  menuitem=$(<"${tempfile}")
  clear
  case $menuitem in
    Resilio) install_resilio ;;
    # Syncthing) install_syncthing ;;
    Exit) exit ;;
  esac
done

rm $tempfile


