#!/bin/bash
#
# Description : Config your joypad controller
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.5.1 (25/Aug/14)
#
clear

#if [ -f ./res/xboxmap ]; then XBOXMAPPATH=./res/xboxmap; else XBOXMAPPATH=./../../res/xboxmap; fi
if [ -f ./res/wii_remote_1.py ]; then WII_TEST_PATH=./res/wii_remote_1.py; else WII_TEST_PATH=./../../res/wii_remote_1.py; fi

tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$

xbox360(){
# sudo nano /opt/retropie/configs/all/retroarch.cfg
# Add the line as follows input_enable_hotkey_btn = 8
# Add the line as follows input_exit_emulator_btn = 9
    dialog --backtitle "piKiss" \
         --title     "[ Config your XBox360 controller ]" \
         --yes-label "Wired" \
         --no-label  "Wireless" \
         --yesno     "Do you have a wired or wireless controller?\nPress [ESC] to Cancel." 7 55

  retval=$?

  case $retval in
    0) W="-id" ;;
    1) W="-wid" ;;
    255) exit ;;
  esac

    clear
    echo "Installing dependences..."
    sudo apt-get install -y xboxdrv
    #cp $XBOXMAPPATH /home/$USER/xboxmap
    #xboxdrv --config /home/$USER/xboxmap --silent
    #$('xboxdrv –trigger-as-button $W 0 –led 2 –detach-kernel-driver –deadzone 4000 –silent &')
    $(xboxdrv –detach-kernel-driver --silent &)
    
  dialog --backtitle "piKiss" \
         --title     "[ Config your XBox360 controller ]" \
         --yes-label "Yes" \
         --no-label  "No" \
         --yesno     "Do you want to run controller on boot?" 7 55

  retval=$?

  case $retval in
    0)   sed -i '$i xboxdrv -trigger-as-button '$W' 0 -led 2 -detach-kernel-driver -deadzone 4000 -silent &\nsleep 1' /etc/rc.local ;;
    1)   exit ;;
  esac

    #echo "Press any button in the controller and test it. When finish, press CTRL+C"
    #cat /dev/input/js0
}

wii(){
    clear
    echo "Installing dependences..."
    sudo apt-get install --no-install-recommends -y bluetooth
    sudo apt-get install python-cwiid

    read -p "Now plug in your Bluetooth dongle, wait about 10 seconds and press [Enter]..."
    BTSTACK=$(sudo service bluetooth status)
    if [[ $BTSTACK == "" ]] ; then
        read -p "Sorry, no Bluetooth device found. Restart with the dongle plug in and try again. Press [Enter] to Exit."
        exit
    else
        read -p "Now will try to test the Wiimote with a Python script from Matt Hawkins (raspberrypi-spy.co.uk). Press [Enter] to Continue."
        $($WII_TEST_PATH)
    fi
}

while true
do
	dialog --backtitle "piKiss" \
		--title 	"[ Config your joypad device ]" --clear \
		--menu  	"Select controller:" 15 55 5 \
        	XBOX360  	"Wired or wireless XBox 360" \
            	WII       	"Wiimote" \
            	Exit        	"Exit" 2>"${tempfile}"

	menuitem=$(<"${tempfile}")

	case $menuitem in
        	XBOX360) xbox360;;
#        	PS3) ;;
        	WII) wii;;
#        	Generic) ;;
        	Exit) exit;;
	esac
done
