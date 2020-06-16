#! /bin/bash
#
# Description : Check Last-Modified field from some distros images, so you can know if a distro is updated.
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.3 (08/Sep/16)
# Compatible  : Raspberry Pi 1, 2 & 3 (tested), ODROID-C1
#
# OpenELEC: https://downloads.raspberrypi.org/openelec_latest
#
clear

. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

CHK_RPi(){
  imgName=(
    'NOOBS'
    'Raspbian'
		'DietPi'
    'pipaOS'
    'Arch Linux'
    'Volumio'
		'LibreELEC'
		'Lakka'
  )
  
  imgUrl=(
    'https://downloads.raspberrypi.org/NOOBS_latest'
    'https://downloads.raspberrypi.org/raspbian_latest'
    'https://dietpi.com/downloads/images/DietPi_RPi-armv6-(Jessie).7z'
    'https://pipaos.mitako.eu/download/pipaos-latest.img.gz'
    'https://os.archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz'
    'https://sourceforge.net/projects/volumio/files/latest/download?source=files'
		'https://releases.libreelec.tv/LibreELEC-RPi2.arm-8.0.2.img.gz'
		'https://le.builds.lakka.tv/RPi2.arm/Lakka-RPi2.arm-2.0.img.gz'
  )
}

CHK_ODROID(){
  imgName=(
    'Arch Linux'
    'Android'
    'Ubuntu'
  )
  
  imgUrl=(
    'https://archlinuxarm.org/os/ArchLinuxARM-odroid-c1-latest.tar.gz'
    'https://dn.odroid.in/S805/Android/ODROID-C/selfinstall-odroidc-eng-s805_4.4.2_master-302-v1.5.img.xz'
    'https://dn.odroid.in/S805/Ubuntu/ubuntu-14.04.2lts-lubuntu-odroid-c1-20150401.img.xz'
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
