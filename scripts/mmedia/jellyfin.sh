#!/bin/bash
#
# Description : Jellyfin
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (24/Jan/20)
# Compatible  : Raspberry Pi 4 (tested)
# Site        : https://jellyfin.org/downloads/
# Help        : For better performance, select Dashboard > Playback: OpenMax OMX and Transcoding thread count: Max
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/apps"
readonly PACKAGES=(apt-transport-https)
readonly IP_LOCAL=$(get_ip)
readonly VIDEO_DEMO_URL="https://content.videvo.net/videvo_files/video/free/2019-05/originalContent/190429_02_Hare_UHD_02.mp4"

remove_files() {
    echo -e "\nCleaning da hause..."
    sudo rm -rf /etc/default/jellyfin /etc/rc3.d/S01jellyfin /etc/jellyfin /etc/init.d/jellyfin \
        /etc/rc6.d/K01jellyfin /etc/apt/sources.list.d/jellyfin.list /etc/rc0.d/K01jellyfin \
        /etc/rc2.d/S01jellyfin /etc/rc1.d/K01jellyfin /etc/init/jellyfin.conf /etc/sudoers.d/jellyfin-sudoers \
        /etc/rc4.d/S01jellyfin /etc/rc5.d/S01jellyfin /etc/systemd/system/jellyfin* \
        /etc/systemd/system/multi-user.target.wants/jellyfin.service /var/log/jellyfin* /var/lib/jellyfin* \
        /var/lib/apt/lists/repo.jellyfin* /var/lib/dpkg/info/jellyfin* \
        /var/lib/systemd/deb-systemd-helper-masked/jellyfin.service /var/cache/jellyfin /usr/bin/jellyfin \
        ~/Videos/190429_02_Hare_UHD_02.mp4
}

uninstall() {
    read -p "Do you want to uninstall Jellyfin (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo apt -y remove jellyfin jellyfin-ffmpeg jellyfin-server jellyfin-web apt-transport-https at
        remove_files
        if [[ -e /usr/bin/jellyfin ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -e /usr/bin/jellyfin ]]; then
    echo -e "Jellyfin already installed.\n"
    uninstall
fi

make_content_dirs() {
    [[ ! -d ~/Videos ]] && mkdir -p ~/Videos
    [[ ! -d ~/Music ]] && mkdir -p ~/Music
    [[ ! -d ~/Pictures ]] && mkdir -p ~/Pictures
}

set_512_RAM_size() {
    echo
    read -p "Recommended 512 RAM. Enable it? (Y/n) " response
    if [[ $response =~ [Nn] ]]; then
        return 0
    fi
    set_GPU_memory 512
}

download_video_demo() {
    [[ -e ~/Videos/190429_02_Hare_UHD_02.mp4 ]] && exit 0
    echo
    read -p "Do you want a 4k video demo (40 Mb) into ~/Videos? (y/N) " response
    if [[ $response =~ [Yy] ]]; then
        echo "
Hare Grazing in Grass Field
A lone hare grazing on grassland.
Please credit: 'Stand Up for Nature', a conservation organisation.
Visit www.standupfornature.org/donate to support their work.
"
        download_file "$VIDEO_DEMO_URL" ~/Videos
    fi
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    wget -O - https://repo.jellyfin.org/jellyfin_team.gpg.key | sudo apt-key add -
    echo "deb [arch=$(dpkg --print-architecture)] https://repo.jellyfin.org/$(awk -F'=' '/^ID=/{ print $NF }' /etc/os-release) $(awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/jellyfin.list
    sudo apt update
    sudo apt install -y jellyfin
    sudo usermod -aG video jellyfin
    sudo systemctl restart jellyfin
    set_512_RAM_size
    make_content_dirs
    download_video_demo
    echo -e "\n\nDone!. REMEMBER to select on web panel: Dashboard > Playback: OpenMax OMX and Transcoding thread count: Max\n\nOpen on your browser the next URL: http://$IP_LOCAL:8096\n\nEnjoy!"
    exit_message
}

install_script_message
echo "
Install Jellyfin
================

 · You need ~200/300 MB storage.
 · For better performance, select on web panel: Dashboard > Playback: OpenMax OMX and Transcoding thread count: Max
 · Web panel when installed: http://$IP_LOCAL:8096
 · On Wizard's form, when ask you Add media library, you can use ~/Videos, ~/Music, ~/Pictures.
 · The service start always on boot. If you want to enable|disable: sudo systemctl start|stop jellyfin
"

read -p "Press [ENTER] to continue..."

install
