#!/bin/bash
#
# Description : Install VNC Server
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9 (29/Mar/16)
#
# HELP        · http://www.stevencombs.com/raspberrypi/2016/03/24/mirror-raspi-monitor-on-mac.html
#
clear

echo -e "Installing VNC Remote Server\n============================"

sudo apt-get install -y x11vnc vnc-java
x11vnc -storepasswd
x11vnc -forever -bg -usepw -httpdir /usr/share/vnc-java/ -httpport 5901 -display :0

echo "Process running on:" $(pgrep x11vnc)
echo "Done. Use a VNC Client and point to vnc://"$(hostname -I)
