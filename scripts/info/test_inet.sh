#!/bin/bash
#
# Description : Test Internet Speed thanks to Matt Martz
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9.2 (29/Dec/14)
# Tested      : Raspbian/Debian/Ubuntu, OSX
#
# IMPROVEMENT : dialog menu with 2 methods.
#
clear


method2(){
	wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test100.zip
}

PYTHON_SCRIPT="https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest_cli.py"

wget $PYTHON_SCRIPT
clear

echo -e "Test Internet bandwidth thanks to Matt Martz\n============================================\n· More Info at: https://github.com/sivel/speedtest-cli\n"

python speedtest_cli.py
rm $HOME/speedtest_cli.py

read -p "Press [Enter] to continue..."