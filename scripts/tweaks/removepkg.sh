#!/bin/bash
#
# Description : Remove packages
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.2.12 (18/Oct/21)
# Compatible  : Raspberry Pi 1-4 (tested)
#
clear

df -h | grep 'root\|Avail'

. ./scripts/helper.sh || . ../helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

pkgs_RPi() {
    echo -e "
Remove packages
===============

· NOTE: This changes can't be undone by PiKISS once applied. Use it at your own risk.
"
    read -p "Do you want to continue? (Y/n) " response
    if [[ $response =~ [Nn] ]]; then
        exit_message
    fi

    if [[ -e /etc/apt/sources.list.d/vscode.list ]]; then
        echo -e "If privacy matter to you, you can always try the project VSCodium that remove telemetry and keep your privacy. Take a look at\nhttps://github.com/VSCodium/vscodium/releases/latest\n"
        read -p "Remove Microsoft VSCode source list?. You can safely install it with PiKISS later (downloaded directly from GitHub repository) (y/n) " option
        case "$option" in
        y*) sudo rm /etc/apt/sources.list.d/vscode.list ;;
        esac
    fi

    # TODO Maybe another method. This is so destructive!
    echo
    read -p "Mmm!, Desktop environment (Warning, this is so destructive!)? (y/n) " option
    case "$option" in
    y*)
        sudo apt remove -y --purge libx11-.* gnome* x11-common* xserver-common lightdm dbus-x11 desktop-base
        sudo apt-get remove -y xkb-data "sudo dpkg --get-selections | grep -v 'deinstall' | grep x11 | sed s/install//"
        ;;
    esac

    echo
    read -p "Remove packages for developers (OK if you're not one)? (y/n) " option
    case "$option" in
    y*)
        sudo apt remove -y "sudo dpkg --get-selections | grep '\-dev' | sed s/install//"
        sudo apt-get remove -y geany thonny
        ;;
    esac

    if isPackageInstalled sonic-pi; then
        echo
        read -p "Remove Sonic Pi (It's a live coding environment based on Ruby)? (Free 24.2 MB) (y/n) " option
        case "$option" in
        y*) sudo apt-get remove -y sonic-pi sonic-pi-samples sonic-pi-server ;;
        esac
    fi

    if isPackageInstalled vlc; then
        echo
        read -p "Remove Video Lan (AKA VLC)? (You always can use omxplayer) (Free 57 MB) (y/n) " option
        case "$option" in
        y*) sudo apt-get remove -y vlc vlc-bin vlc-data vlc-l10n vlc-plugin-base vlc-plugin-notify vlc-plugin-qt vlc-plugin-samba vlc-plugin-skins2 vlc-plugin-video-output vlc-plugin-video-splitter vlc-plugin-visualization ;;
        esac
    fi

    if isPackageInstalled scratch || isPackageInstalled scratch2 || isPackageInstalled scratch3; then
        echo
        read -p "Remove Scratch (1,2 & 3)? (Free 147 MB) (y/n) " option
        case "$option" in
        y*) sudo apt-get remove -y scratch scratch2 scratch3 ;;
        esac
    fi

    if isPackageInstalled libreoffice; then
        echo
        read -p "Remove LibreOffice? (Free 310 MB) (y/n) " option
        case "$option" in
        y*) sudo apt-get remove -y "sudo dpkg --get-selections | grep -v 'deinstall' | grep libreoffice | sed s/install//" ;;
        esac
    fi

    if isPackageInstalled snapd; then
        echo
        read -p "Remove Snap daemon (You can remove it if don't use Snap Apps)? (y/n) " option
        case "$option" in
        y*) sudo apt-get remove -y snapd ;;
        esac
    fi

    # alsa?, wavs, ogg?
    echo
    read -p "Delete all related with sound? (audio support, VLC) (y/n) " option
    case "$option" in
    y*) sudo apt remove -y "sudo dpkg --get-selections | grep -v 'deinstall' | grep sound | sed s/install//" ;;
    esac

    echo
    read -p "Other unneeded packages:  libraspberrypi-doc, manpages. (Free 39.3 MB) (y/n) " option
    case "$option" in
    y*) sudo apt remove -y libraspberrypi-doc manpages ;;
    esac

    echo
    read -p "You don't use a printer, so remove all cups packages (y/n) " option
    case "$option" in
    y*) sudo apt remove -y cups* ;;
    esac

    sudo apt-get -y autoremove --purge && sudo apt-get clean
    clear
    df -h | grep 'root\|Avail'
    echo "Have a nice day and don't blame me!."
    exit_message
}

install_script_message
pkgs_RPi
