#!/bin/bash
#
# Description : Test Internet Speed thanks to Matt Martz
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (9/Apr/15)
# Tested      : Raspbian/Debian/Ubuntu, OSX
#
#
clear

PYTHON_SCRIPT="https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest_cli.py"

wget -P $HOME $PYTHON_SCRIPT
clear

echo -e "Test Internet bandwidth thanks to Matt Martz\n============================================\n· More Info at: https://github.com/sivel/speedtest-cli\n"

[ -f $HOME/speedtest_cli.py ] && python $HOME/speedtest_cli.py
rm $HOME/speedtest_cli.py

read -p "Press [Enter] to continue..."