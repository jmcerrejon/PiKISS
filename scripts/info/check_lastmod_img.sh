#! /bin/bash
#
# Description : Check Last-Modified field from some distros images, so you can know if a distro is updated.
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (29/May/14)
#
clear

echo "Check Last-Modified field from some distros images"
echo "=================================================="

declare -a imgName=(
			'pipaOS'
			'OpenELEC'
			'Arch Linux'
			'MinePeon'
			'PiPlay (PiMAME)'
			'ArkOS'
			'Volumio'
)
declare -a imgUrl=(
			'http://pipaos.mitako.eu/'
			'http://openelec.tv/get-openelec/download/finish/10-raspberry-pi-builds/343-diskimage-openelec-stable-raspberry-pi-arm'
			'http://archlinuxarm.org/os/ArchLinuxARM-rpi-latest.zip'
			'http://sourceforge.net/projects/minepeon/files/latest/download?source=files'
			'http://sourceforge.net/projects/pimame/files/latest/download?source=files'
			'https://nyus.mirror.arkos.io/os/latest-rpi.tar.gz'
			'http://sourceforge.net/projects/volumio/files/latest/download?source=files'
)

i=0
while [ $i -lt ${#imgName[*]} ]; do
    echo ${imgName[$i]} $(wget -qS --spider ${imgUrl[$i]} 2>&1 | grep 'Last-Modified.*GMT')
    i=$(( $i + 1));
done

read -p "Press [Enter] to continue..."

