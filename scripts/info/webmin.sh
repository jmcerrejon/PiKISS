#!/bin/bash
#
# Description : Webmin
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.4 (17/Jan/19)
# Compatible  : Raspberry Pi 1, 2 & 3 all versions (tested)
#
# HELP		  : http://msrobotics.net/index.php/com-virtuemart-menu-categories/laboratorio-pi/41-instala-webmin-y-administra-de-forma-grafica-raspbian-via-web
#
clear

IP=$(hostname -I)
WEBMIN_URL='https://netix.dl.sourceforge.net/project/webadmin/webmin/1.900/webmin_1.900_all.deb'

echo -e "Installing Webmin\n=================\n\nPlease wait..."
sudo apt-get install -y perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions libapt-pkg-perl python

cd $HOME
wget $WEBMIN_URL

sudo dpkg -i webmin*.deb
rm webmin_*.deb

read -p "Done!. Now you can go to http://$IP:10000 on your web browser. Press [ENTER] to continue..."
