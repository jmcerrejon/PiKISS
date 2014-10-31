#! /bin/bash
#
# Description : Check Last-Modified field from some distros images, so you can know if a distro is updated.
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1 (31/Aug/14)
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
            'RaspBMC'
			'Arch Linux'
            'Risc OS'
			'MinePeon'
			'PiPlay (PiMAME)'
			'ArkOS'
			'Volumio'
			'ScoutBot'
			'OpenELEC'
)
declare -a imgUrl=(
            'http://downloads.raspberrypi.org/NOOBS_latest'
            'http://downloads.raspberrypi.org/raspbian_latest'
            'http://downloads.raspberrypi.org/pidora_latest'
			'http://pipaos.mitako.eu/'
            'http://download.raspbmc.com/downloads/bin/filesystem/prebuilt/raspbmc-final.img.gz'
			'http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz'
            'http://downloads.raspberrypi.org/riscos_latest'
			'http://sourceforge.net/projects/minepeon/files/latest/download?source=files'
			'http://sourceforge.net/projects/pimame/files/latest/download?source=files'
			'https://nyus.mirror.arkos.io/os/latest-rpi.tar.gz'
			'http://sourceforge.net/projects/volumio/files/latest/download?source=files'
			'http://sourceforge.net/projects/scoutbot/files/latest/download?source=files'
			'http://openelec.tv/get-openelec/download/finish/10-raspberry-pi-builds/605-diskimage-openelec-stable-raspberry-pi-arm'
)

i=0
while [ $i -lt ${#imgName[*]} ]; do
    echo ${imgName[$i]} $(wget -qS --spider ${imgUrl[$i]} 2>&1 | grep 'Last-Modified.*GMT')
    i=$(( $i + 1));
done

read -p "Press [Enter] to continue..."

