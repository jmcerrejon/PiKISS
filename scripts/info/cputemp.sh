#!/bin/bash
#
# Description : Show CPU temperature
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9 (7/May/14)
#
clear

echo $(/opt/vc/bin/vcgencmd measure_temp)

read -p "Press [Enter] to continue..."
