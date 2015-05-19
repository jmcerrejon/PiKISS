#! /bin/bash
#
# Description : Check Last-Modified field from some distros images, so you can know if a distro is updated.
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.2 (11/May/15)
# Compatible  : Raspberry Pi 1 & 2, ODROID-C1
#
# OpenELEC: http://downloads.raspberrypi.org/openelec_latest
# 
clear

. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

CHK_RPi(){
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
}

CHK_ODROID(){
	declare -a imgName=(
		'Arch Linux'
		'Android'
		'Ubuntu'
	)

	declare -a imgUrl=(
		'http://archlinuxarm.org/os/ArchLinuxARM-odroid-c1-latest.tar.gz'
		'http://dn.odroid.in/S805/Android/ODROID-C/selfinstall-odroidc-eng-s805_4.4.2_master-302-v1.5.img.xz'
		'http://dn.odroid.in/S805/Ubuntu/ubuntu-14.04.2lts-lubuntu-odroid-c1-20150401.img.xz'
	)
}

echo -e "Check Last-Modified field from some distros images\n=================================================="

if [[ ${MODEL} == 'Raspberry Pi' ]]; then
  CHK_RPi
elif [[ ${MODEL} == 'ODROID-C1' ]]; then
  CHK_ODROID
fi

i=0
while [ $i -lt ${#imgName[*]} ]; do
    echo ${imgName[$i]} $(wget -qS --spider ${imgUrl[$i]} 2>&1 | grep 'Last-Modified.*GMT')
    i=$(( $i + 1));
done

read -p "Press [Enter] to continue..."

