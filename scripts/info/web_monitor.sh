#!/bin/bash
#
# Description : Web monitor from http://geekytheory.com
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.2 (5/Apr/15)
# Compatible  : Raspberry Pi 1, 2 & 3 (tested)
#
# IMPROVEMENT : linux-dash -> http://pplware.sapo.pt/linux/linux-dash-monitorize-o-seu-linux-a-distancia/
#
clear

IP=$(hostname -I)

install(){
	sudo apt-get install -y nodejs npm
	cd $HOME
	git clone https://github.com/GeekyTheory/Raspberry-Pi-Status.git
	cd Raspberry-Pi-Status
	sudo npm config set registry http://registry.npmjs.org/
	sudo npm install
}

echo -e "Web monitor with Node.js by http://geekytheory.com\n==================================================\n\n· This script install nodejs, npm\n· 13.5 MB of additional disk space will be used.\n· More Info: http://geekytheory.com/panel-de-monitorizacion-para-raspberry-pi-con-node-js\n\n"

read -p "Are you sure you want to continue? [y/n] " option
case "$option" in
    n*) exit ;;
esac

install

echo -e "Starting Web monitor!... Now you can go to http://$IP:8000 on your browser."
nodejs server.js
