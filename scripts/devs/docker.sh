#!/bin/bash
#
# Description : Docker
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.1 (05/Nov/24)
# Tested      : Raspberry Pi 5
#
# shellcheck source=../helper.sh
. ../helper.sh || . ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly PACKAGES=(firewalld)
readonly DOCKER_DEBIAN_INFO_URL="https://docs.docker.com/engine/install/debian/"
readonly TEMP_PATH="/tmp"

download_latest_deb_files() {
    if is_userspace_64_bits; then
        local URL="https://download.docker.com/linux/debian/dists/bookworm/pool/stable/arm64/"
    else
        local URL="https://download.docker.com/linux/debian/dists/bookworm/pool/stable/armhf/"
    fi
    CONTAINERD_FILENAME=$(wget -q -O - "$URL" | grep containerd.io | awk -F "\"" '{print $2}' | sort -V | tail -n 1)
    DOCKER_CE_FILENAME=$(wget -q -O - "$URL" | grep docker-ce | awk -F "\"" '{print $2}' | sort -V | tail -n 1)
    DOCKER_CE_CLI_FILENAME=$(wget -q -O - "$URL" | grep docker-ce-cli | awk -F "\"" '{print $2}' | sort -V | tail -n 1)
    DOCKER_BUILDX_PLUGIN_FILENAME=$(wget -q -O - "$URL" | grep docker-buildx-plugin | awk -F "\"" '{print $2}' | sort -V | tail -n 1)
    DOCKER_COMPOSE_PLUGIN_FILENAME=$(wget -q -O - "$URL" | grep docker-compose-plugin | awk -F "\"" '{print $2}' | sort -V | tail -n 1)

    [[ ! -f $TEMP_PATH/${CONTAINERD_FILENAME} ]] && wget -P $TEMP_PATH "${URL}${CONTAINERD_FILENAME}"
    [[ ! -f $TEMP_PATH/${DOCKER_CE_FILENAME} ]] && wget -P $TEMP_PATH "${URL}${DOCKER_CE_FILENAME}"
    [[ ! -f $TEMP_PATH/${DOCKER_CE_CLI_FILENAME} ]] && wget -P $TEMP_PATH "${URL}${DOCKER_CE_CLI_FILENAME}"
    [[ ! -f $TEMP_PATH/${DOCKER_BUILDX_PLUGIN_FILENAME} ]] && wget -P $TEMP_PATH "${URL}${DOCKER_BUILDX_PLUGIN_FILENAME}"
    [[ ! -f $TEMP_PATH/${DOCKER_COMPOSE_PLUGIN_FILENAME} ]] && wget -P $TEMP_PATH "${URL}${DOCKER_COMPOSE_PLUGIN_FILENAME}"
}

uninstall() {
    read -p "Do you want to uninstall Docker (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo docker system prune -a -f
        sudo apt remove -y docker-ce docker-ce-cli containerd.io
        sudo rm -rf /var/lib/docker /var/lib/containerd /etc/docker /etc/containerd /etc/systemd/system/docker.service.d /etc/systemd/system/containerd.service.d /usr/bin/docker /usr/bin/dockerd /usr/bin/containerd /usr/bin/ctr /usr/bin/docker-compose /usr/bin/docker-buildx /usr/bin/dockerd-rootless-setuptool.sh /usr/bin/dockerd-rootless.sh /usr/bin/docker-init /usr/bin/docker-proxy /usr/bin/docker-containerd /usr/bin/docker-containerd-ctr /usr/bin/docker-containerd-shim /usr/bin/docker-containerd-shim-runc-v2 /usr/bin/docker-runc /usr/bin/docker-containerd-shim-runc-v1 /usr/bin/docker-containerd-ctr /usr/bin/docker-containerd-shim /usr/bin/docker-containerd-shim-runc-v2 /usr/bin/docker-runc /usr/bin/docker-containerd-shim-runc-v1 /usr/bin/docker-containerd-ctr /usr/bin/docker-containerd-shim /usr/bin/docker-containerd-shim-runc-v

        sudo groupdel docker

        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
}

if [[ -x "$(command -v docker)" ]]; then
    echo -e "Docker already installed.\n"
    uninstall
fi

post_install() {
    echo -e "\nAdding user to docker group..."
    sudo groupadd docker
    sudo usermod -aG docker "$USER"
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    download_latest_deb_files

    cd "$TEMP_PATH" || exit
    sudo dpkg -i "./$CONTAINERD_FILENAME" \
        "./$DOCKER_CE_FILENAME" \
        "./$DOCKER_CE_CLI_FILENAME" \
        "./$DOCKER_BUILDX_PLUGIN_FILENAME" \
        "./$DOCKER_COMPOSE_PLUGIN_FILENAME"

    echo -e "\nInstalled $(docker -v) | Kernel PAGESIZE: $(getconf PAGESIZE)\n"
    post_install
    systemctl status docker.service
    sudo systemctl start docker
    read -p "Do you want to enable at boot? (y/N) " response
    if [[ $response =~ [Yy] ]]; then
        sudo systemctl enable docker
    fi
    echo -e "\nDone!. You can try it using the command: sudo docker run hello-world"
    exit_message
}

install_script_message
echo "
Docker
======

· Docker is a set of platform as a service products that use OS-level virtualization to deliver software in packages called containers.
· This script is using the manual process to install it, because sometimes the official repository is not updated.
· Download the latest version at the time you install it.
· More info: $DOCKER_DEBIAN_INFO_URL
"
read -p "Press [ENTER] to continue..."
install
