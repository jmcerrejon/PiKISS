#!/bin/bash
#
# Description : Install VNC Server
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (12/Sep/16)
#
clear

echo -e "Installing VNC Remote Server\n============================"

sudo apt-get install -y x11vnc vnc-java
x11vnc -storepasswd
x11vnc -forever -bg -usepw -httpdir /usr/share/vnc-java/ -httpport 5901 -display :0
clear
echo "Process running on:" $(pgrep x11vnc)
echo "Done. Use a VNC Client and point to vnc://"$(hostname -I)
read -p 'Press [ENTER] to continue...'
