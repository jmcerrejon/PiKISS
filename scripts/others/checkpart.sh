#! /bin/bash
#
# Description : check partition to search and fix errors on Raspbian/Ubuntu
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9 (2/Sep/14)
#
clear

dialog  --title     "[ Check partition & fix errors]" \
        --yes-label "Yes" \
        --no-label  "No" \
        --yesno     "I need to restart the system to fix errors. Agreed?" 7 60

response=$?
case $response in
   0) sudo touch /forcefsck ; echo "The system is restarting..."; sudo shutdown -rF now ;;
   1) echo "None done. Exiting...";;
   255) echo "[ESC] key pressed.";;
esac

read -p "Press [ENTER] to continue..."