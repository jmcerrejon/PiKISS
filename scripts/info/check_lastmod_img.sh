#! /bin/bash
#
# Description : Check Last-Modified field from some distros images, so you can know if a distro is updated.
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.3 (08/Sep/16)
# Compatible  : Raspberry Pi 1, 2 & 3 (tested), ODROID-C1
#
# OpenELEC: http://downloads.raspberrypi.org/openelec_latest
#
clear

. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

CHK_RPi(){
	imgName=(
	    'NOOBS'
	    'Raspbian'
		'OpenELEC'
		'Domoticz'
		'pipaOS'
		'DietPi'
	    'PiDora'
		'Arch Linux'
	    'Risc OS'
		'MinePeon'
		'PiPlay (PiMAME)'
		'Volumio'
		'OpenELEC RPi2'
	)

	imgUrl=(
        'http://downloads.raspberrypi.org/NOOBS_latest'
        'http://downloads.raspberrypi.org/raspbian_latest'
		'http://openelec.tv/get-openelec/category/7-raspberry-pi2-builds?download=31:raspberry-pi-2-and-pi3-model-b-512mb-diskimage'
		'http://sourceforge.net/projects/domoticz/files/latest/download?source=files'
		'http://dietpi.com/downloads/images/DietPi_RPi-armv6-(Jessie).7z'
		'http://pipaos.mitako.eu/'
        'http://downloads.raspberrypi.org/pidora_latest'
		'http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz'
        'http://downloads.raspberrypi.org/riscos_latest'
		'http://sourceforge.net/projects/minepeon/files/latest/download?source=files'
		'http://sourceforge.net/projects/pimame/files/latest/download?source=files'
		'http://sourceforge.net/projects/volumio/files/latest/download?source=files'
		'http://releases.openelec.tv/OpenELEC-RPi2.arm-5.0.8.img.gz'
	)
}

CHK_ODROID(){
	imgName=(
		'Arch Linux'
		'Android'
		'Ubuntu'
	)

	imgUrl=(
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

tLen=${#imgName[@]}
for (( i=0; i<${tLen}; i++ )); do
    echo ${imgName[$i]} $(wget -qS --spider ${imgUrl[$i]} 2>&1 | grep 'Last-Modified.*GMT')
done

read -p "Press [Enter] to continue..."
