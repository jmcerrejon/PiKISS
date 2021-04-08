#!/bin/bash
#
# Description : Compile QT5 on Raspberry Pi
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.3 (13/Dec/20)
# Compatible  : Raspberry Pi 4
#
# Thks		  : Based in the script at https://github.com/MarkusIppy/QT5.12.4-raspian-Buster-EGLFS
# TODO		  : Ask for install and remove sources. Check if install_packages is OK, pi with less then 2 GB ram
#				will need to increase the swap file size.
# Links       : https://www.cyberpunk.rs/building-raspberry-pi-gui
# Links       : https://www.interelectronix.com/qt-on-the-raspberry-pi-4.html
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

QT5_SC_URL="http://download.qt.io/official_releases/qt/5.15/5.15.0/single/qt-everywhere-src-5.15.0.tar.xz"
INPUT=/tmp/qt5menu.$$

init() {
    sudo gpasswd -a pi render

    sudo mkdir /opt/QT5
    sudo chown pi:pi /opt/QT5
    echo "{ \"device\": \"/dev/dri/card1\" }" >> /opt/QT5/eglfs.json

    upgrade_dist
}

install_packages() {
    echo -e "\nInstalling some dependencies...\n"
    sudo apt install -y clang libegl1-mesa-dev libgbm-dev libgles2-mesa-dev mesa-common-dev \
    libclang-dev libatspi-dev build-essential libfontconfig1-dev libdbus-1-dev libfreetype6-dev \
    libicu-dev libinput-dev libxkbcommon-dev libsqlite3-dev libssl-dev libpng-dev libjpeg-dev \
    libglib2.0-dev libraspberrypi-dev
    
    while true; do
        echo " "
        read -p "Do you need bluetooth library support? [y/n] " yn
        case $yn in
            [Yy]* ) sudo apt-get install -y bluez libbluetooth-dev && break;;
            [Nn]* ) break;;
            * ) echo "Please answer (y)es or (n)o.";;
        esac
    done

    while true; do
        echo " "
        read -p "Do you need gstreamer library for Multimedia support? [y/n] " yn
        case $yn in
            [Yy]* ) sudo apt-get install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad libgstreamer-plugins-bad1.0-dev gstreamer1.0-pulseaudio gstreamer1.0-tools gstreamer1.0-alsa && break;;
            [Nn]* ) break;;
            * ) echo "Please answer (y)es or (n)o.";;
        esac
    done

    while true; do
        echo " "
        read -p "Do you need audio support? [y/n] " yn
        case $yn in
            [Yy]* ) sudo apt-get install -y libasound2-dev && break;;
            [Nn]* ) break;;
            * ) echo "Please answer (y)es or (n)o.";;
        esac
    done

    while true; do
        echo " "
        read -p "Do you need Database support (PostgreSQL, MySQL)? [y/n] " yn
        case $yn in
            [Yy]* ) sudo apt-get install -y libpq-dev libmariadbclient-dev && break;;
            [Nn]* ) break;;
            * ) echo "Please answer (y)es or (n)o.";;
        esac
    done

    while true; do
        echo " "
        read -p "Do you need X11 support? [y/n] " yn
        case $yn in
            [Yy]* ) sudo apt-get install -y libx11-dev libxcb1-dev libxkbcommon-x11-dev libx11-xcb-dev libxext-dev && break;;
            [Nn]* ) break;;
            * ) echo "Please answer (y)es or (n)o.";;
        esac
    done

    while true; do
        echo " "
        read -p "Do you want experimental VC4 driver instead of Broadcom EGL binary-blobs? [y/n] " yn
        case $yn in
            [Yy]* ) sudo apt-get install -y libgles2-mesa-dev libgbm-dev && break;;
            [Nn]* ) break;;
            * ) echo "Please answer (y)es or (n)o.";;
        esac
    done
}

download_QT5() {
    echo -e "\nDownloading QT 5...\n"
    cd "$HOME"
    wget "$QT5_SC_URL"
    echo -e "\nUncompressing, please wait...\n"
    tar xf qt-everywhere-src-*.tar.xz
    sudo rm -r qt-everywhere-src-*.tar.xz
}

compile_QT5() {
    echo -e "\nCompile QT with 4 cores. Go for a walk or watch 2 movies...\n"

    cd qt-everywhere-src-*
    PKG_CONFIG_LIBDIR=/usr/lib/arm-linux-gnueabihf/pkgconfig:/usr/share/pkgconfig \
    ../qt-everywhere-src-5.12.8/configure -platform linux-rpi-g++ \
    -v \
    -opengl es2 -eglfs \
    -no-gtk \
    -opensource -confirm-license -release \
    -reduce-exports \
    -force-pkg-config \
    -nomake examples -no-compile-examples \
    -skip qtwayland \
    -skip qtwebengine \
    -no-feature-geoservices_mapboxgl \
    -qt-pcre \
    -no-pch \
    -ssl \
    -evdev \
    -system-freetype \
    -fontconfig \
    -glib \
    -prefix /opt/Qt5 \
    -qpa eglfs

    make -j"$(getconf _NPROCESSORS_ONLN)"
}

setup() {
    echo "Add enviroment variables to bashrc"
    echo 'export LD_LIBRARY_PATH=/opt/QT5/lib' >> "$HOME"/.bashrc 
    echo 'export PATH=/opt/QT5/bin:$PATH' >> "$HOME"/.bashrc 
    source "$HOME"/.bashrc
}

setup_mkspecs() {
    cd "$HOME"
    git clone https://github.com/oniongarlic/qt-raspberrypi-configuration.git
}

compile_menu() {
    echo -e "Warning:\n========\n· This script compiles QT5 ready for Raspberry Pi 4.\n· If you want qtwebengine, remove the -skip qtwebengine line inside this script.\n· Make your you have enough space on device.\n· Qt source archive: 483MB, Unpacked Qt Sources: 2.8GB, Build result: 745MB, Install size: 155MB - 300MB (Depends on configuration options and enabled features)\n· This process can take about 4-6 hours to compile on Rpi 4.\n· If you use a Pi with less then 2 GB RAM then you will need to increase the swap file size.\n· Make sure you use a fan to keep your board fresh.\n· Consider overclocking your Pi before running this script.\n· If you need additional help, visit https://www.tal.org/tutorials/building-qt-512-raspberry-pi\n\n"

    while true; do
        echo " "
        read -p "Proceed? [y/n] " yn
        case $yn in
        [Yy]* ) init; install_packages; download_QT5; compile_QT5 && echo -e "\nDone!. Just type sudo make install";;
        [Nn]* ) exit;;
        [Ee]* ) exit;;
        * ) echo "Please answer (y)es, (n)o or (e)xit.";;
        esac
    done
}

install_from_repo() {
    sudo apt install -y qtbase5-dev qt5-qmake qtchooser
    read -p "Done. Press [ENTER] to come back to the menu..."
    exit
}

menu() {
    while true
    do
        dialog --clear   \
            --title     "[ Qt5 Library ]" \
            --menu      "Select from the list:" 11 68 3 \
            Install   "5.11 binary and get qmake command OTB." \
            Compile   "latest from source code. Estimated time: 4-6 hours." \
            Exit    "Exit" 2>"${INPUT}"

        menuitem=$(<"${INPUT}")

        case $menuitem in
            Install) clear ; install_from_repo ;;
            Compile) clear ; compile_menu ;;
            Exit) exit ;;
        esac
    done
}

menu
