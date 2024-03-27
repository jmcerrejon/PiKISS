#!/bin/bash
#
# Description : Vulkan driver
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.5.1 (21/Mar/24)
# Tested      : Raspberry Pi 4-5
#
# Help        : https://ninja-build.org/manual.html#ref_pool
#             : https://qengineering.eu/install-vulkan-on-raspberry-pi.html
#             : https://blogs.igalia.com/apinheiro/2020/06/v3dv-quick-guide-to-build-and-run-some-demos/
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

install_vulkan_from_official_repository() {
    local CODENAME
    CODENAME=$(get_codename)

    if [ "$CODENAME" != "bullseye" ]; then
        echo -e "You need at least Debian Bullseye to install Vulkan. See: https://wiki.debian.org/bullseye"
        return 0
    fi

    echo -e "\nInstalling Vulkan driver from official repository...\n"
    sudo apt install -y mesa-vulkan-drivers libvulkan-dev libvulkan1 vulkan-tools
    echo
    glxinfo -B
    echo "Done."
    exit_message
}

install_script_message
echo "
Vulkan Mesa Drivers
===================

Installs vulkan drivers from official apt repositories.
"
read -p "Continue? (Y/n) " response
if [[ $response =~ [Nn] ]]; then
    exit_message
fi
upgrade_dist
install_vulkan_from_official_repository
exit_message
