#!/bin/bash
#
# Description : Web monitor from http://geekytheory.com
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.1 (14/May/14)
#
clear

IP=$(hostname -I)

echo -e "Web monitor with Node.js by http://geekytheory.com\n==================================================· More Info: http://geekytheory.com/panel-de-monitorizacion-para-raspberry-pi-con-node-js\n"

sudo apt-get install -y nodejs npm git
cd $HOME
git clone https://github.com/GeekyTheory/Raspberry-Pi-Status.git
cd Raspberry-Pi-Status
sudo npm config set registry http://registry.npmjs.org/
sudo npm install

echo -e "Starting Web monitor!... Now you can go to http://$IP:8000 on your browser."
nodejs server.js