#! /bin/bash
#
# Description : Pairing a Bluetooth keyboard
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0 (12/Jun/14)
#
# IMPROVEMENT : Pair any device with dialog
#             · https://www.pi-supply.com/make/fix-raspberry-pi-3-bluetooth-issues/
#
clear

BTDEVICE=hci0
lsusb | grep -i bluetooth | grep -i "bluetooth" > /dev/null 2>&1
CHECKBT=$?

#FILE="
##! /bin/bash
#sudo /etc/init.d/bluetooth restart
#sudo /etc/init.d/dbus start
#sudo update-rc.d -f dbus defaults
#sudo hciconfig $BTDEVICE up
#"

# Search for BT dongle

if [ $CHECKBT -eq 0 ]; then
    if [ ! -e /usr/bin/hcitool ]; then
        echo -e " \e[00;36mInstalling Bluetooth stacks (19.3 MB aprox.)...\e[00m\n"
        sudo apt-get install -y --no-install-recommends bluetooth bluez-utils blueman
    fi
else
    echo -e " \e[00;31mNo bluetooth device found. Make sure is plugged and reboot.\e[00m\n"
    read -p "Press [ENTER] to continue..."
    exit
fi

# BT status

/etc/init.d/bluetooth status | grep -e "fail" > /dev/null 2>&1
CHECKBT=$?

if [ $CHECKBT -eq 1 ]; then
    echo -e " \e[00;36mStarting bluetooth...\e[00m\n"
    sudo /etc/init.d/bluetooth restart
    sudo hciconfig $BTDEVICE up
else
    echo -e " \e[00;36mBluetooth is running...\e[00m\n"
fi

# Search the keyboard

read -p "Put your keyboard in discover mode (switch on), wait 5 seconds and press [ENTER]..."

echo -e "\n\e[00;36mSearching for keyboard...\e[00m\n"

# Add grep -e to the list below with the name of your keyboard
BTMAC=$(hcitool scan | grep -e Teclado -e keyboard -e Keyboard -e Cambridge -e K760| awk '{print $1}')

if [ ! -z "$BTMAC" ]; then
    echo -e " \e[00;36mKeyboard found!: $BTMAC\e[00m\n"
else
    echo -e " \e[00;31mNo keyboard found. Try again or edit the script and add to the BTMAC variable the name of your keyboard.\n$BTMAC\e[00m\n"
    read -p "Press [ENTER] to continue..."
    exit
fi

# Enable DBUS
sudo /etc/init.d/dbus start
sudo update-rc.d -f dbus defaults

# Pairing the device

echo -e "\nWhen you’re prompted to enter a pin number, type a 4 digit numeric code into your USB keyboard and press return.\nThe PIN code you enter doesn’t matter, so pick something like 1234.\nThen type the same PIN code into your keyboard and press return."
sudo bluez-simple-agent $BTDEVICE $BTMAC
# Another method: sudo bluetooth-agent --adapter $BTDEVICE 1234 $BTMAC

# Trust and connect the keyboard for future use
sudo bluez-test-device trusted $BTMAC yes
sudo bluez-test-input connect $BTMAC

#If doesn't Work: sudo bluez-simple-agent hci0 $BTMAC repair
echo -e "\n\nType in your keyboard and good luck\nWhen reboot, if doesn't work, type:\n\n sudo bluez-simple-agent hci0 $BTMAC repair\n\nand start the script again.\Another method is lauch in another terminal the command:\n\nsudo hcidump -at | grep -i passkey\n\nto see the bluetooth pairing key if authentication fail."
read -p "Press [ENTER] to continue..."
