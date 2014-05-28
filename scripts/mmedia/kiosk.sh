#!/bin/bash
#
# Description : Config your joypad controller
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (26/May/14)
#
# IMPROVEMENT · dir dialog to ask path
#
clear

IMG_PATH_D="$HOME/imgs"
IMG_TRANS_D="5"

if [[ ! -f /usr/bin/fbi ]] ; then
    sudo apt-get install -y fbi
fi

echo -e "Kiosk mode with fbi\n===================\n"

read -r -p "Please enter full path to images folder (Default: $IMG_PATH_D): " "IMG_PATH"
read -r -p "Seconds to next image transition (Default: $IMG_TRANS_D sec.): " "IMG_TRANS"

IMG_PATH=${IMG_PATH:-$IMG_PATH_D}
IMG_TRANS=${IMG_TRANS:-$IMG_TRANS_D}

sudo fbi -m "1920x1080-60" --autoup -a -u -t "$IMG_TRANS" -noverbose -readahead -blend 2 -d /dev/fb0 -T 2 "$IMG_PATH"/*.*