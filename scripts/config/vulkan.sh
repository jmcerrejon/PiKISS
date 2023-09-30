#!/bin/bash
#
# Description : Vulkan driver
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.4.7 (30/Sep/23)
# Compatible  : Raspberry Pi 4
#
# Help        : https://ninja-build.org/manual.html#ref_pool
#             : https://qengineering.eu/install-vulkan-on-raspberry-pi.html
#             : https://blogs.igalia.com/apinheiro/2020/06/v3dv-quick-guide-to-build-and-run-some-demos/
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/mesa_vulkan"
readonly SOURCE_CODE_URL="https://gitlab.freedesktop.org/mesa/mesa.git"
PI_VERSION_NUMBER=$(get_pi_version_number)
BRANCH_VERSION="mesa-23.2.1"
INPUT=/tmp/vulkan.$$

install() {
    echo -e "\nInstalling,...\n"
    cd "$INSTALL_DIR" || exit
    sudo ninja -C build install
    echo
    glxinfo -B
    echo "Done."
    exit_message
}

install_full_deps() {
    echo -e "\nInstalling deps...\n"
    sudo apt-get install -y libxcb-randr0-dev libxrandr-dev \
        libxcb-xinerama0-dev libxinerama-dev libxcursor-dev \
        libxcb-cursor-dev libxkbcommon-dev xutils-dev \
        xutils-dev libpthread-stubs0-dev libpciaccess-dev \
        libffi-dev x11proto-xext-dev libxcb1-dev libxcb-*dev \
        bison flex libssl-dev libgnutls28-dev x11proto-dri2-dev \
        x11proto-dri3-dev libx11-dev libxcb-glx0-dev \
        libx11-xcb-dev libxext-dev libxdamage-dev libxfixes-dev \
        libva-dev x11proto-randr-dev x11proto-present-dev \
        libclc-dev libelf-dev git build-essential mesa-utils \
        libvulkan-dev ninja-build libvulkan1 python3-mako \
        libdrm-dev libxshmfence-dev libxxf86vm-dev libwayland-dev \
        python3-mako wayland-protocols libwayland-egl-backend-dev \
        cmake libassimp-dev python3-pip
    install_meson
}

clone_repo() {
    echo -e "\nCloning mesa repo...\n"
    cd || exit
    git clone -b "$BRANCH_VERSION" "$SOURCE_CODE_URL" "$INSTALL_DIR" && cd "$_" || exit
}

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

compile_and_install_libdrm() {
    local LIBDRM_URL
    local SOURCE_CODE_PATH
    FILE_NAME="libdrm-2.4.115"
    LIBDRM_URL="https://dri.freedesktop.org/libdrm/$FILE_NAME.tar.xz"
    SOURCE_CODE_PATH="$HOME/sc"

    echo -e "\nCompiling libdrm...\n"
    download_and_extract "$LIBDRM_URL" "$SOURCE_CODE_PATH"
    cd "$FILE_NAME" || exit
    [[ ! -d build ]] && mkdir build
    cd build || exit
    meson setup -Dudev=true -Dvc4=auto -Dintel=disabled -Dvmwgfx=disabled -Dradeon=disabled -Damdgpu=disabled -Dnouveau=disabled -Dfreedreno=disabled -Dinstall-test-programs=true ..
    time ninja -C . -j"$(nproc)"
    sudo ninja install
    echo "Compiled & installed onto your system. Move on..."
}

compile() {
    local EXTRA_PARAM
    EXTRA_PARAM="-mcpu=cortex-a72 -mfpu=neon-fp-armv8"

    [[ -d $INSTALL_DIR ]] && rm -rf "$INSTALL_DIR"
    install_full_deps
    compile_and_install_libdrm
    clone_repo

    [[ -d "$INSTALL_DIR"/build ]] && rm -rf "$INSTALL_DIR"/build

    if is_userspace_64_bits; then
        EXTRA_PARAM="-mcpu=cortex-a72"
    fi

    meson setup --prefix /usr -Dgles1=disabled -Dgles2=enabled -Dplatforms=x11 -Dxlib-lease=auto -Dvulkan-drivers=broadcom -Dgallium-drivers=v3d,kmsro,vc4,virgl,zink -Dbuildtype=release -Dc_args="$EXTRA_PARAM" -Dcpp_args="$EXTRA_PARAM" build
    echo -e "\nCompiling... \n"
    time ninja -C build -j"$(nproc)"
    install
}

menu_choose_branch() {
    while true; do
        dialog --clear \
            --title "[ Vulkan Branch ]" \
            --menu "Select from the list:" 11 100 3 \
            repo "(Quicker) Not latest but stable from official repository." \
            stable "(Recommended) Latest stable branch working ${BRANCH_VERSION}." \
            main "(Latest) NOT stable at all. Install at your own risk." \
            Exit "Exit" 2>"${INPUT}"

        menuitem=$(<"${INPUT}")

        case $menuitem in
        repo) install_vulkan_from_official_repository ;;
        stable) compile ;;
        main) BRANCH_VERSION="main" && compile ;;
        Exit) exit ;;
        esac
    done
}

install_script_message
echo "
Vulkan Mesa Drivers
===================

· Support 32/64 bits.
· This process can't be undone.
· Make sure you have a backup of your data.
· This script installs or compiles Vulkan Mesa Driver on your OS.
· Estimated compilation time on Raspberry Pi 4 over USB/SSD drive (Not overclocked): ~19 min.
"
read -p "Continue? (Y/n) " response
if [[ $response =~ [Nn] ]]; then
    exit_message
fi
upgrade_dist
menu_choose_branch
exit_message
