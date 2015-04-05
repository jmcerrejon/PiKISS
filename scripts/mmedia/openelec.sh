#!/bin/bash
#
# Description : OpenELEC Extras
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.6 (7/Jan/15)
#
# HELP		  : zip -r AdvLauncher_uLySeSS.zip /storage/.kodi/addons/emulator.tools.retroarch/ /storage/.kodi/addons/plugin.program.advanced.launcher/ /storage/.kodi/addons/script.module.simplejson/ /storage/.kodi/userdata/addon_data/emulator.tools.retroarch/ /storage
#/.kodi/userdata/addon_data/plugin.program.advanced.launcher/
# 
clear

advancedsettings(){
	file="<advancedsettings>
	<network>
	<buffermode>1</buffermode>
	<cachemembuffersize>0</cachemembuffersize>
	<readbufferfactor>4.0</readbufferfactor>
	</network>
</advancedsettings>"

	echo $file > /storage/.kodi/userdata/advancedsettings.xml
}

retroarch(){
	wget http://misapuntesde.com/res/AdvLauncher_uLySeSS.zip
	unzip AdvLauncher_uLySeSS.zip -d /
	rm AdvLauncher_uLySeSS.zip
	killall -9 kodi.bin
}

backup(){
	DATE=`date +%Y%m%e-%H%M%S`
	zip -r /storage/backup/bckup_$DATE.zip /storage/.kodi/addons/ /storage/.kodi/userdata/
	read -p "backup done!. Enable Samba on OpenELEC and navigate to //OPENELEC/Backup/"
}

echo -e "OpenELEC Extras for Kodi\n"

read -p "Increase video buffer?. (y/n)" option
case "$option" in
    y*) advancedsettings ;;
esac

read -p "Install RetroArch emulators?. (y/n)" option
case "$option" in
    y*) retroarch ;;
esac

read -p "Backup Addons+Userdata?. (y/n)" option
case "$option" in
    y*) backup ;;
esac

read -p "Have a nice Day :)"