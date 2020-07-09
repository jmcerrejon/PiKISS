#!/bin/bash
#
# Description : Webmin
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (09/Jul/20)
# Compatible  : Raspberry Pi 1-4 (tested)
#
# HELP		  : https://msrobotics.net/index.php/com-virtuemart-menu-categories/laboratorio-pi/41-instala-webmin-y-administra-de-forma-grafica-raspbian-via-web
#
clear

IP=$(hostname -I)
WEBMIN_URL='https://netix.dl.sourceforge.net/project/webadmin/webmin/1.953/webmin_1.953_all.deb'

download() {
	cd "$HOME"
	wget "$WEBMIN_URL"
}

install() {
	echo -e "\nInstalling Webmin\n=================\n\nPlease wait..."
	sudo apt-get install -y perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions libapt-pkg-perl python
	download
	sudo dpkg -i webmin*.deb
	rm webmin_*.deb
}
install

read -p "Done!. Now you can go to https://${IP}:10000 on your web browser. Some extra info:\n · FAQ: http://www.webmin.com/faq.html\n · The app is installed at /usr/share/webmin\n · User and password: Any user in the system (maybe pi with password raspberry?)"
read -p "Press [ENTER] to go back to the menu..."
