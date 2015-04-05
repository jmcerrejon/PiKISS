#! /bin/bash
#
# Description : Check Last-Modified field from some distros images, so you can know if a distro is updated.
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.2 (11/Apr/15)
#
# OpenELEC: http://downloads.raspberrypi.org/openelec_latest
# 
clear

echo "Check Last-Modified field from some distros images"
echo "=================================================="

declare -a imgName=(
            'NOOBS'
            'Raspbian'
            'PiDora'
			'pipaOS'
            'OSMC RPi2'
			'Arch Linux'
            'Risc OS'
			'MinePeon'
			'PiPlay (PiMAME)'
			'ArkOS'
			'Volumio'
			'OpenELEC RPi2'
			'Domoticz'
)
declare -a imgUrl=(
            'http://downloads.raspberrypi.org/NOOBS_latest'
            'http://downloads.raspberrypi.org/raspbian_latest'
            'http://downloads.raspberrypi.org/pidora_latest'
			'http://pipaos.mitako.eu/'
            'http://download.osmc.tv/installers/diskimages/OSMC_TGT_rbp2_20150315.img.gz'
			'http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz'
            'http://downloads.raspberrypi.org/riscos_latest'
			'http://sourceforge.net/projects/minepeon/files/latest/download?source=files'
			'http://sourceforge.net/projects/pimame/files/latest/download?source=files'
			'https://nyus.mirror.arkos.io/os/latest-rpi.tar.gz'
			'http://sourceforge.net/projects/volumio/files/latest/download?source=files'
			'http://releases.openelec.tv/OpenELEC-RPi2.arm-5.0.8.img.gz'
			'http://sourceforge.net/projects/domoticz/files/latest/download?source=files'
)

i=0
while [ $i -lt ${#imgName[*]} ]; do
    echo ${imgName[$i]} $(wget -qS --spider ${imgUrl[$i]} 2>&1 | grep 'Last-Modified.*GMT')
    i=$(( $i + 1));
done

read -p "Press [Enter] to continue..."

