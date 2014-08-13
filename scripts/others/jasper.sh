#! /bin/bash
#
# Description : Jasper, an open source platform for developing always-on, voice-controlled applications
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.1 (25/Jun/14)
#               UNFINISHED
#
# HELP        · http://jasperproject.github.io/documentation/software/
#
clear

echo -e "Jasper\n======\n · An open source platform for developing always-on, voice-controlled applications\n\nInstalling, please wait..."

sudo apt-get install git-core espeak python-dev python-pip bison libasound2-dev libportaudio-dev python-pyaudio --yes

sudo sed -i 's/options snd-usb-audio index=-2/options snd-usb-audio index=0/g' /etc/modprobe.d/alsa-base.conf

read -p "Now plug in your USB Microphone and press [ENTER] to rec 10 seconds of audio..."

sudo alsa force-reload

echo "Recording..."
arecord -d 10 /tmp/temp.wav

echo "Playing..."
omxplayer /tmp/temp.wav

