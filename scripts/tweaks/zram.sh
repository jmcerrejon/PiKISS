#!/bin/bash
#
# Description : Enable/Disable ZRAM
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (07/Jul/20)
# Compatible  : Raspberry Pi 1-4
#
. ../helper.sh || . ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

set -e
free -wth

enableZRAM() {
    echo -e "\nEnabling ZRAM...\n"
    cat <<\EOF >/tmp/zram
#!/bin/bash

CORES=$(nproc --all)
modprobe zram num_devices=${CORES}
swapoff -a
SIZE=$(( ($(free | grep -e "^Mem:" | awk '{print $2}') / ${CORES}) * 1024 ))
CORE=0
while [ ${CORE} -lt ${CORES} ]; do
  echo ${SIZE} > /sys/block/zram${CORE}/disksize
  mkswap /dev/zram${CORE} > /dev/null
  swapon -p 5 /dev/zram${CORE}
  (( CORE += 1 ))
done
EOF
    chmod +x /tmp/zram
    sudo mv /tmp/zram /etc/zram
    sudo /etc/zram
    if [ "$(grep -c zram /etc/rc.local)" -eq 0 ]; then
        sudo sed -i 's_^exit 0$_/etc/zram\nexit 0_' /etc/rc.local
    fi
}

removeZRAM() {
    echo -e "\nRemoving ZRAM...\n"
    CORES=$(nproc --all)
    CORE=0
    while [ ${CORE} -lt "${CORES}" ]; do
        sudo swapoff /dev/zram${CORE}
        ((CORE += 1))
    done
    wait
    sleep .5
    sudo modprobe --remove zram
    sudo sed -i '/zram/d' /etc/rc.local
    sudo rm /etc/zram
    sudo /etc/init.d/dphys-swapfile stop >/dev/null
    sudo /etc/init.d/dphys-swapfile start >/dev/null
}

if [ -e /etc/zram ]; then
    echo
    read -p "ZRAM already installed. Remove it (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        removeZRAM
    fi
else
    echo
    read -p "ZRAM is not present. Enable it (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        enableZRAM
    fi
fi

echo
free -wth
echo
read -p "Done!. Press [Enter] to come back to the menu..."
