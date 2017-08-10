#!/bin/bash
#
# OctoPrint installer
 
. ../helper.sh

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SERVICE_FILE="
[Unit]
Description=OctoPrint service
After=network.target

[Service]
Type=simple 
PIDFile=/tmp/octoprint.pid
User=$USER
ExecStart=/home/$USER/OctoPrint/venv/bin/python /home/$USER/OctoPrint/venv/bin/octoprint serve       

[Install]
"


sudo apt-get update
sudo apt-get install -y python-pip python-dev python-setuptools python-virtualenv virtualenv git libyaml-dev build-essential

sudo usermod -a -G tty ${USER}
sudo usermod -a -G dialout ${USER}

cd ~

git clone https://github.com/foosel/OctoPrint.git || exit
cd OctoPrint
virtualenv venv
. venv/bin/activate
pip install pip --upgrade
python setup.py install 
mkdir ~/.octoprint

sudo bash -c "echo \"${SERVICE_FILE}\" > /etc/systemd/system/octoprint.service" 
sudo systemctl daemon-reload

read -p "Done!. Press [Enter] to continue..."
