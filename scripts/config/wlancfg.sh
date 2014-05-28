#!/bin/bash -x
#
# Description : Config your wlan0 device
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.1 (11/May/14)
#
# TODO:       · Ask if you have more than one wlan
#
# PI: sudo iwlist wlan0 scanning  | egrep 'ESSID' | sed 's|[ESSID:"]||g'
# UBUNTU: sudo iw wlan0 scan | egrep 'SSID' | sed 's/://g' | awk '{print $1, $2}'
#
clear

DEVICE=$(cat /proc/net/dev | egrep 'wlan' | sed 's/://g' | awk '{print $1 $1}')
SSID=$(sudo iw wlan0 scan | egrep 'SSID' | sed 's/://g' | awk '{print $2, $1}')
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$

dialog --backtitle "WLAN Configurator" \
     --title     '[ Set your wlan device ]' --clear \
     --menu      "Please choose a network device:" 15 55 5 $SSID 2>"${tempfile}"
   
SSID=$(<"${tempfile}")

# To be continue...