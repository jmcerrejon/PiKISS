#!/bin/bash
#################################################
# Aircrack-ng Installer For Raspberry Pi        #
#												                        #
# Made By Robert Wiggins					            	#
# txt3rob@gmail.com							              	#
#												                        #
# USE AT YOUR OWN RISK & TEST ONLY ON YOUR OWN  #
# HARDWARE NOT ANY ONE ELSES				          	#
#											                        	#
#################################################
echo "Starting Updating APT"
sudo apt-get update
echo "Installing Dependencys"
sudo apt-get install libssl-dev subversion iw libnl-dev macchanger sqlite3 reaver -y
sudo apt-get install libnl-3-dev libnl-genl-3-dev -y
echo "Grabbing Aircrack From SVN"
svn co http://svn.aircrack-ng.org/trunk/ aircrack-ng 
cd aircrack-ng 
make 
sudo make install
sudo airodump-ng-oui-update
cd scripts
chmod +x airmon-ng
cp airmon-ng /usr/bin/airmon-ng
cd /root/
echo "Grabbing Airoscript From SVN"
sudo svn co http://svn.aircrack-ng.org/branch/airoscript-ng/ airoscript-ng
cd airoscript-ng
sudo make
cd /root/
echo "done"
