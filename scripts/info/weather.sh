#!/bin/bash
#
# Description : Get Weather Info
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1 (09/Sep/16)
#
# Help:
# · http://api.openweathermap.org/data/2.5/forecast/daily?q=Huelva&mode=xml&units=metric&cnt=7&lang=sp
# · convert from epoch to human readable format: date -d @1399687200 - http://www.epochconverter.com/#code
#
clear

if [ -d "./bin" ]; then PATH=$PATH:./bin; else XBOXMAPPATH=./../../bin; fi
export PATH
COUNTRY="Huelva,ES"

if  ! which /usr/bin/jq >/dev/null ; then
    sudo apt -y install jq bc
fi

echo "AnsiWeather is developed by Frederic Cambus"
echo "==========================================="
echo -e "More Info: https://github.com/fcambus/ansiweather\n"

echo "Enter your country and press [Enter]:"
read COUNTRY

clear
echo "Fetching data for $COUNTRY (5 days)..."

ansiweather -l $COUNTRY -u metric -s true -f 5 -d true

read -p "Press [Enter] to continue..."
