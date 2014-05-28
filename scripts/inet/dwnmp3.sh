#!/bin/bash
#
# Description : A Grooveshark song downloader in python by George Stephanos <gaf.stephanos@gmail.com>
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.9 (12/May/14)
#
# TODO        · Loop menu to download more than one file
#
clear

if [ -d ./res/ ]; then SCRIPT=./res; else SCRIPT=./../../res; fi
echo -e "A Grooveshark song downloader by George Stephanos\n=================================================\nJust type a song or artist:"
read SONG

#($SCRIPT' "'$SONG'"')
cd $SCRIPT
./groove.py ' "'$SONG'"'
echo "Song downloaded to "$SCRIPT
read -p "Press [Enter] to continue..."