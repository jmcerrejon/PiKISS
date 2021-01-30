#!/bin/bash
#
# Description : Install REmote desktop apps
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (30/Jan/21)
# Compatible  : Raspberry Pi 4 (tested)
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/apps"
readonly PACKAGES_VNC=(x11vnc vnc-java)
readonly NOMACHINE_BINARY_NAME="nomachine_7.0.211_1_armhf.deb"
readonly NOMACHINE_BINARY_URL="https://download.nomachine.com/download/7.0/Raspberry/$NOMACHINE_BINARY_NAME"
readonly INPUT=/tmp/temp.$$

# VNC

uninstall_vnc() {
    if [[ ! -e /usr/bin/x11vnc ]]; then
        return 0
    fi
    read -p "Do you want to uninstall VNC Server (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo apt remove -y x11vnc vnc-java libvncclient1 libvncserver1 tcl tk x11vnc-data
        sudo rm -rf /usr/share/x11vnc /usr/share/doc/x11vnc-data
        if [[ -e /usr/bin/x11vnc ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

install_vnc() {
    uninstall_vnc
    install_script_message
    echo -e "Installing VNC Remote Server\n============================"
    install_packages_if_missing "${PACKAGES_VNC[@]}"
    x11vnc -storepasswd
    x11vnc -forever -bg -usepw -httpdir /usr/share/vnc-java/ -httpport 5901 -display :0
    echo "Process running on:" "$(pgrep x11vnc)"
    echo "Done. Use a VNC Client and point to vnc://$(hostname -I)"
    exit_message
}

# XRDP

uninstall_xrdp() {
    if [[ ! -e /usr/sbin/xrdp ]]; then
        return 0
    fi
    read -p "Do you want to uninstall XRDP Server (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo apt remove -y xrdp
        sudo rm -rf /home/pi/.local/share/xrdp /home/pi/.local/share/xrdp /etc/default/xrdp /etc/rc3.d/S01xrdp /etc/init.d/xrdp \
            /etc/rc6.d/K01xrdp /etc/rc0.d/K01xrdp /etc/rc2.d/S01xrdp /etc/rc1.d/K01xrdp /etc/rc4.d/S01xrdp /etc/X11/xrdp \
            /etc/pam.d/xrdp-sesman /etc/rc5.d/S01xrdp /etc/systemd/system/xrdp.service \
            /etc/systemd/system/xrdp-sesman.service /etc/systemd/system/multi-user.target.wants/xrdp.service \
            /etc/systemd/system/multi-user.target.wants/xrdp-sesman.service /var/log/xrdp.log \
            /var/log/xrdp-sesman.log /var/lib/dpkg/info/xorgxrdp.conffiles /var/lib/dpkg/info/xrdp.list \
            /var/lib/dpkg/info/xorgxrdp.md5sums /var/lib/dpkg/info/xrdp.postrm /var/lib/dpkg/info/xorgxrdp.list \
            /var/lib/systemd/deb-systemd-helper-masked/xrdp.service /var/lib/systemd/deb-systemd-helper-masked/xrdp-sesman.service \
            /var/lib/systemd/deb-systemd-helper-enabled/xrdp-sesman.service.dsh-also \
            /var/lib/systemd/deb-systemd-helper-enabled/xrdp.service.dsh-also \
            /var/lib/systemd/deb-systemd-helper-enabled/multi-user.target.wants/xrdp.service \
            /var/lib/systemd/deb-systemd-helper-enabled/multi-user.target.wants/xrdp-sesman.service \
            /usr/share/lintian/overrides/xorgxrdp /usr/share/doc/xorgxrdp /usr/lib/xorg/modules/libxorgxrdp.a \
            /usr/lib/xorg/modules/input/xrdpkeyb_drv.a /usr/lib/xorg/modules/input/xrdpkeyb_drv.so \
            /usr/lib/xorg/modules/input/xrdpmouse_drv.so /usr/lib/xorg/modules/input/xrdpkeyb_drv.la \
            /usr/lib/xorg/modules/input/xrdpmouse_drv.la /usr/lib/xorg/modules/input/xrdpmouse_drv.a \
            /usr/lib/xorg/modules/drivers/xrdpdev_drv.la /usr/lib/xorg/modules/drivers/xrdpdev_drv.a \
            /usr/lib/xorg/modules/drivers/xrdpdev_drv.so /usr/lib/xorg/modules/libxorgxrdp.so /usr/lib/xorg/modules/libxorgxrdp.la
        if [[ -e /usr/sbin/xrdp ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

install_xrdp() {
    uninstall_xrdp
    install_script_message
    install_backports
    sudo apt -y -t buster-backports install xrdp
    sudo service xrdp restart
    remove_backports
    echo -e "\n\nDone!. On Windows you can use Remote Desktop | On macOS, search on App Store Microsoft Remote Desktop"
    exit_message
}

# NoMachine

uninstall_nomachine() {
    if [[ ! -e /usr/NX ]]; then
        return 0
    fi
    read -p "Do you want to uninstall Nomachine (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo apt remove -y nomachine && sudo rm -rf /usr/NX /home/pi/.nx /media/nomachine
        if [[ -e /usr/NX ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

install_nomachine() {
    uninstall_nomachine
    install_script_message
    echo -e "\nInstaling Nomachine, be patience...\n"
    download_file "$NOMACHINE_BINARY_URL" "/tmp"
    sudo dpkg -i "$NOMACHINE_BINARY_NAME"
    echo -e "\n\nDone!. Download the client at https://www.nomachine.com/ and enjoy!"
    exit_message
}

menu() {
    while true; do
        dialog --clear \
            --title "[ Remote Desktop Apps ]" \
            --menu "Select from the list:" 11 70 3 \
            NOMACHINE "Only RPi 4.Fastest and highest quality remote desktop (Recommended)" \
            XRDP "Remote desktop server based on the Remote Desktop Protocol (RDP)" \
            VNC "VNC Server from official repositories" \
            Exit "Exit" 2>"${INPUT}"

        menuitem=$(<"${INPUT}")

        case $menuitem in
        NOMACHINE) clear && install_nomachine ;;
        XRDP) clear && install_xrdp ;;
        VNC) clear && install_vnc ;;
        Exit) exit ;;
        esac
    done
}

menu
