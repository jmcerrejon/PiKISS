#!/bin/bash
#
# OctoPrint installer
 
. scripts/helper.sh

BASE_DIR="/opt"
# BASE_DIR="/home/${USER}"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SERVICE_FILE="
[Unit]
Description=OctoPrint service
After=network.target

[Service]
Type=simple 
PIDFile=/tmp/octoprint.pid
User=$USER
ExecStart=${BASE_DIR}/OctoPrint/venv/bin/python ${BASE_DIR}/OctoPrint/venv/bin/octoprint serve       

"


sudo apt-get update
sudo apt-get install -y python-pip python-dev python-setuptools python-virtualenv virtualenv git libyaml-dev build-essential

sudo usermod -a -G tty ${USER}
sudo usermod -a -G dialout ${USER}

cd ${BASE_DIR}
sudo mkdir -m 777 OctoPrint
git clone https://github.com/foosel/OctoPrint.git OctoPrint || exit
cd OctoPrint
virtualenv venv
. venv/bin/activate
pip install pip --upgrade
python setup.py install 

cd "${BASE_DIR}/OctoPrint"
sudo cp scripts/octoprint.init /etc/init.d/octoprint
sudo chmod +x /etc/init.d/octoprint
sudo cp scripts/octoprint.default /etc/default/octoprint
sudo bash -c "echo \"DAEMON=${BASE_DIR}/OctoPrint/venv/bin/octoprint 
OCTOPRINT_USER=${USER}\">> /etc/default/octoprint"
sudo update-rc.d octoprint defaults

mkdir ~/.octoprint

sudo bash -c "echo \"${SERVICE_FILE}\" > /etc/systemd/system/octoprint.service" 
sudo systemctl daemon-reload

read -p "Done!. Press [Enter] to continue..."
