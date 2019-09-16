#!/bin/bash
#
# Description : Remove packages
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.2.7 (16/Sep/19)
# Compatible  : Raspberry Pi 1-4 (tested)
#
clear

df -h | grep 'root\|Avail'

. ./scripts/helper.sh || . ../helper.sh || . ./helper.sh || wget -q 'http://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

pkgs_ODROID(){
    echo -e "\nRemove packages for ODROID Ubuntu\n=================================\n"
    sudo apt-get --purge remove bluez bluez-alsa bluez-cups
    sudo apt-get remove chromium-browser chromium-browser-l10n chromium-codecs-ffmpeg-extra
    sudo apt-get remove cups cups-bsd cups-client cups-common cups-core-drivers cups-daemon cups-ppdc cups-server-common
    sudo apt-get remove firefox firefox-locale-en
    sudo apt-get remove kodi
    sudo apt-get remove oracle-java8-installer
    sudo apt-get remove audacious audacious-plugins-data
}

pkgs_RPi(){
    echo -e "\nRemove packages\n===============\n"
    # Maybe another method. This is so destructive!
    read -p "Mmm!, Desktop environment (Warning, this is so destructive!)? (y/n) " option
    case "$option" in
        y*) sudo apt remove -y --purge libx11-.* gnome* x11-common* xserver-common lightdm dbus-x11 desktop-base; sudo apt-get remove -y xkb-data `sudo dpkg --get-selections | grep -v "deinstall" | grep x11 | sed s/install//` ;;
    esac

    read -p "Remove packages for developers (OK if you're not one)? (y/n) " option
    case "$option" in
        y*) sudo apt remove -y `sudo dpkg --get-selections | grep "\-dev" | sed s/install//`; sudo apt-get remove -y geany; ;;
    esac

	if isPackageInstalled sonic-pi; then
		read -p "Remove Sonic Pi (It's a live coding environment based on Ruby)? (Free 24.2 MB) (y/n) " option
		case "$option" in
			y*) sudo apt-get remove -y sonic-pi sonic-pi-samples sonic-pi-server ;;
		esac
	fi

	if isPackageInstalled vlc; then
		read -p "Remove Video Lan (AKA VLC)? (You always can use omxplayer) (Free 57 MB) (y/n) " option
		case "$option" in
			y*) sudo apt-get remove -y vlc vlc-bin vlc-data vlc-l10n vlc-plugin-base vlc-plugin-notify vlc-plugin-qt vlc-plugin-samba vlc-plugin-skins2 vlc-plugin-video-output vlc-plugin-video-splitter vlc-plugin-visualization ;;
		esac
	fi

	if isPackageInstalled scratch || isPackageInstalled scratch2 || isPackageInstalled scratch3; then
		read -p "Remove Scratch (1,2 & 3)? (Free 147 MB) (y/n) " option
		case "$option" in
			y*) sudo apt-get remove -y scratch scratch2 scratch3 ;;
		esac
	fi

	if isPackageInstalled libreoffice; then
		read -p "Remove LibreOffice? (Free 310 MB) (y/n) " option
		case "$option" in
			y*) sudo apt-get remove -y `sudo dpkg --get-selections | grep -v "deinstall" | grep libreoffice | sed s/install//` ;;
		esac
	fi

    # alsa?, wavs, ogg?
    read -p "Delete all related with sound? (audio support, VLC) (y/n) " option
    case "$option" in
        y*) sudo apt remove -y `sudo dpkg --get-selections | grep -v "deinstall" | grep sound | sed s/install//` ;;
    esac

    read -p "Other unneeded packages:  libraspberrypi-doc, manpages. (Free 39.3 MB) (y/n) " option
    case "$option" in
        y*) sudo apt remove -y libraspberrypi-doc manpages ;;
    esac
}

pkgs_RPi

sudo apt-get autoremove -y && sudo apt-get clean

clear
df -h | grep 'root\|Avail'
read -p "Have a nice day and don't blame me!. Press [Enter] to continue..."
