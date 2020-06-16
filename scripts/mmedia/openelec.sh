#!/bin/bash
#
# Description : OpenELEC Extras
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 0.7.1 (24/Jun/15)
#
# HELP		  : zip -r AdvLauncher_uLySeSS.zip /storage/.kodi/addons/emulator.tools.retroarch/ /storage/.kodi/addons/plugin.program.advanced.launcher/ /storage/.kodi/addons/script.module.simplejson/ /storage/.kodi/userdata/addon_data/emulator.tools.retroarch/ /storage
#/.kodi/userdata/addon_data/plugin.program.advanced.launcher/
#			  · https://forum.kodi.tv/showthread.php?tid=201354
#			  · https://kodi.wiki/view/Raspberry_Pi
#			  · resize partition: touch /storage/.please_resize_me
#			  · Install Pulsar from https://kodi.speedbox.me/svn_kodi/trunk/repository.kodiunderground/repository.kodiunderground-1.0.3.zip | https://sourceforge.net/projects/icanuckxbmcrepo/files/latest/download?source=files
# 			  · 
#
clear

advancedsettings(){
	file="<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n
<advancedsettings>\n
<network>\n
<cachemembuffersize>25165824</cachemembuffersize>\n
<buffermode>1</buffermode>\n
<limitcacherate>false</limitcacherate>\n
</network>\n
</advancedsettings>"

	echo $file > /storage/.kodi/userdata/advancedsettings.xml
}

optimize(){
	mount /flash -o rw,remount
	# Backup the config file
 	[[ ! -e /flash/config.bak ]] && cp /flash/config.txt /flash/config.bak
	#noram and disable splash decrease boot times
	echo -e "noram\ndisable_splash=1" | tee -a /flash/config.txt
	# I dunno what the hell do the next
	[[ ! -e /storage/.config/udev.rules.d/80-io-scheduler.rules ]] && touch /storage/.config/udev.rules.d/80-io-scheduler.rules
	echo -e 'ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="deadline"' | tee -a /storage/.config/udev.rules.d/80-io-scheduler.rules
	#Overclocking 950 Mhz Rpi | 1000 Mhz Rpi2
	echo -e "arm_freq=950\ncore_freq=450\nsdram_freq=450\nover_voltage=6" | tee -a /flash/config.txt

	
	# Tweak the system UI and others. It does not work. I don't know why. Grrr!

	# sed -i 's/        <enablerssfeeds>true<\/enablerssfeeds>/        <enablerssfeeds>false<\/enablerssfeeds>/g' /storage/.kodi/userdata/guisettings.xml
	# sed -i 's/        <soundskin default="true">SKINDEFAULT<\/soundskin>/        <soundskin>OFF<\/soundskin>/g' /storage/.kodi/userdata/guisettings.xml
	# sed -i 's/        <setting type="bool" name="skin.confluence.HomeMenuNoWeatherButton">false<\/setting>/        <setting type="bool" name="skin.confluence.HomeMenuNoWeatherButton">true<\/setting>/g' /storage/.kodi/userdata/guisettings.xml
	# sed -i 's/        <setting type="bool" name="skin.confluence.HomeMenuNoPicturesButton">false<\/setting>/        <setting type="bool" name="skin.confluence.HomeMenuNoPicturesButton">true<\/setting>/g' /storage/.kodi/userdata/guisettings.xml
	# sed -i 's/        <setting type="bool" name="skin.confluence.HomeMenuNoMusicButton">false<\/setting>/        <setting type="bool" name="skin.confluence.HomeMenuNoMusicButton">true<\/setting>/g' /storage/.kodi/userdata/guisettings.xml
	# sed -i 's/        <setting type="bool" name="skin.confluence.HomeMenuNoProgramsButton">false<\/setting>/        <setting type="bool" name="skin.confluence.HomeMenuNoProgramsButton">true<\/setting>/g' /storage/.kodi/userdata/guisettings.xml
	# sed -i 's/        <setting type="bool" name="skin.confluence.HideVisualizationFanart">false<\/setting>/        <setting type="bool" name="skin.confluence.HideVisualizationFanart">true<\/setting>/g' /storage/.kodi/userdata/guisettings.xml
	# sed -i 's/        <setting type="bool" name="skin.confluence.HideBackGroundFanart">false<\/setting>/        <setting type="bool" name="skin.confluence.HideBackGroundFanart">true<\/setting>/g' /storage/.kodi/userdata/guisettings.xml

}

retroarch(){
	wget https://misapuntesde.com/res/AdvLauncher_uLySeSS.zip
	unzip AdvLauncher_uLySeSS.zip -d /
	rm AdvLauncher_uLySeSS.zip
	killall -9 kodi.bin
}

pelisalacarta(){
	wget https://blog.tvalacarta.info/descargas/pelisalacarta-xbmc-addon-gotham-3.9.99.zip
	unzip pelisalacarta-xbmc-addon-gotham-3.9.99.zip -d /storage/.kodi/addons/
	rm pelisalacarta-xbmc-addon-gotham-3.9.99.zip
	killall -9 kodi.bin
}

backup(){
	DATE=`date +%Y%m%e-%H%M%S`
	zip -r /storage/backup/bckup_$DATE.zip /storage/.kodi/addons/ /storage/.kodi/userdata/
	read -p "backup done!. Enable Samba on OpenELEC and navigate to //OPENELEC/Backup/"
}

echo -e "OpenELEC Extras for Kodi\n"

read -p "Increase video buffer? [y/n]: " option
case "$option" in
    y*) advancedsettings ;;
esac

read -p "Optimize the system? [y/n]: " option
case "$option" in
    y*) optimize ;;
esac

read -p "Install RetroArch emulators? [y/n]: " option
case "$option" in
    y*) retroarch ;;
esac

read -p "Install addon pelisalacarta 3.9.99? [y/n]: " option
case "$option" in
    y*) pelisalacarta ;;
esac

read -p "Backup Addons+Userdata? [y/n]: " option
case "$option" in
    y*) backup ;;
esac

echo -e "Have a nice Day :)\n"
#reboot