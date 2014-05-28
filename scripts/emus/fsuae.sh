#!/bin/bash
#
# Description : FS-UAE with OpenGL ES compatibility for Raspberry Pi thanks to cnvogelg
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (16/May/14)
#
clear

read -p "Unfinished. You can end the script and submit to PiKiSS Git repo. Press [ENTER]..."
exit

mkdir -P $HOME/sc
cd sc
git clone https://github.com/cnvogelg/fs-uae-gles.git
cd fs-uae-gles
sudo apt-get install -y libglib2.0-dev libsdl1.2-dev

echo "FS-UAE-GLES for Raspberry Pi (compile)"
echo "======================================"
echo -e "More Info: https://github.com/cnvogelg/fs-uae-gles\n"