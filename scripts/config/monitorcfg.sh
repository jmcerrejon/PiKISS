#!/bin/bash
#
# Description : Modify config.txt according to your TV screen preferences
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (5/Apr/15)
#
# HELP        · http://weblogs.asp.net/bleroy/getting-your-raspberry-pi-to-output-the-right-resolution
#
clear

sudo mount -o remount,rw /boot
tvservice -d edid > /tmp/edid
edidparser edid | grep 'mode (' | sed -e 's/\<HDMI:EDID\>//g' | sed -e 's/^[ \t]*//' > /tmp/modes
cat -n /tmp/modes > /tmp/modes_num
INPUT=/tmp/menu.sh.$$
trap "rm $INPUT; exit" SIGHUP SIGINT SIGTERM
ar=()

while read n s ; do
    ar+=($n "$s")
done < /tmp/modes_num
dialog  --title "[ TV/Monitor resolution settings ]" --menu "Choose a resolution to modify /boot/config.txt: " 30 90 90 "${ar[@]}" 2>"${INPUT}"

menuitem=$(<"${INPUT}")

SELECTED=$(sed $menuitem'q;d' /tmp/modes)

HDMI_TYPE=$(echo "$SELECTED" | awk '{print $1}')
HDMI_MODE=$(echo "$SELECTED" | awk '{print $3}' | tr -d '()')

if [ "$HDMI_TYPE" = "DMT" ]; then
  HDMI_GROUP=2
else
  HDMI_GROUP=1
fi

sudo sed -i '/hdmi_group\|hdmi_mode/d' /boot/config.txt

sudo sh -c 'echo "hdmi_group='$HDMI_GROUP'" >> /boot/config.txt'
sudo sh -c 'echo "hdmi_mode='$HDMI_MODE'" >> /boot/config.txt'

[ -f $INPUT ] && rm $INPUT

dialog --title "[ /boot/config.txt ]" --textbox /boot/config.txt 50 85
