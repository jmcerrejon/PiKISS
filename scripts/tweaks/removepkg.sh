#!/bin/bash
#
# Description : Remove packages
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.2.4 (17/Jan/19)
# Compatible  : Raspberry Pi 1,2 & 3 (tested)
#
clear

df -h | grep 'root\|Avail'


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

    read -p "Remove Java(TM) SE Runtime Environment 1.8.0 & Wolfram-engine (646 MB space will be freed)? (y/n) " option
    case "$option" in
        y*) sudo apt remove --purge -y oracle-java8-jdk ;;
    esac

    read -p "Say with me: I don't wanna use Scratch. Delete it (you free 240 MB!)? (y/n) " option
    case "$option" in
        y*) sudo apt remove --purge -y scratch* ;;
    esac

    # alsa?, wavs, ogg?
    read -p "Delete all related with sound? (audio support, VLC) (y/n) " option
    case "$option" in
        y*) sudo apt remove -y `sudo dpkg --get-selections | grep -v "deinstall" | grep sound | sed s/install//` ;;
    esac

    # read -p "Do you really need Sense-Hat? (y/n) " option
    # case "$option" in
    #     y*) sudo apt remove -y python-sense-emu python3-sense-emu python-sense-emu-doc sense-emu-tools;;
    # esac

    read -p "Other unneeded packages:  libraspberrypi-doc, manpages. (Free 36.8 MB) (y/n) " option
    case "$option" in
        y*) sudo apt remove -y libraspberrypi-doc manpages ;;
    esac
}

pkgs_RPi

sudo apt-get autoremove -y && sudo apt-get clean

clear
df -h | grep 'root\|Avail'
read -p "Have a nice day and don't blame me!. Press [Enter] to continue..."
