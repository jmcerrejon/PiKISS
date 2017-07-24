#!/bin/bash
#
# Description : Test Internet Speed thanks to Matt Martz
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1 (24/Jul/17)
# Tested      : Raspbian/Debian/Ubuntu, OSX
#
clear

PYTHON_SCRIPT="https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py"
SPEED_TEST="$HOME/speedtest.py"

wget -P ~ "$PYTHON_SCRIPT"
clear

echo -e "Test Internet bandwidth thanks to Matt Martz\n============================================\n· More Info at: https://github.com/sivel/speedtest-cli\n"

[ -f "$SPEED_TEST" ] && python "$SPEED_TEST"
rm "$SPEED_TEST"

read -p "Done!. Press [Enter] to continue..."
