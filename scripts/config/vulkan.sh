#!/bin/bash
#
# Description : Vulkan driver
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.3.0 (16/Nov/21)
# Compatible  : Raspberry Pi 4
#
# Info        : Thks to PI Labs
# Help        : https://ninja-build.org/manual.html#ref_pool
#             : https://www.raspberrypi.org/forums/viewtopic.php?f=63&t=276412&start=25#p1678723
#             : https://blogs.igalia.com/apinheiro/2020/06/v3dv-quick-guide-to-build-and-run-some-demos/
#             : https://github.com/Yours3lf/rpi-vk-driver/blob/master/BUILD.md
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/mesa_vulkan"
readonly BRANCH_VERSION="21.3"
readonly SOURCE_CODE_URL="https://gitlab.freedesktop.org/mesa/mesa/-/tree/$BRANCH_VERSION"
readonly PI_VERSION_NUMBER=$(get_pi_version_number)

install() {
    echo -e "\nInstalling,...\n"
    cd "$INSTALL_DIR" || exit
    sudo ninja -C build install
    echo
    glxinfo -B
    echo "Done."
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
    git clone -b 20.3 https://gitlab.freedesktop.org/mesa/mesa.git "$INSTALL_DIR" && cd "$_" || exit
}

compile() {
    local EXTRA_PARAM

    [[ -d $INSTALL_DIR ]] && rm -rf "$INSTALL_DIR"
    install_full_deps
    clone_repo

    [[ -d "$INSTALL_DIR"/build ]] && rm -rf "$INSTALL_DIR"/build

    if [[ $PI_VERSION_NUMBER -eq 4 ]]; then
        EXTRA_PARAM="-mcpu=cortex-a72 -mfpu=neon-fp-armv8 -mfloat-abi=hard"
    fi

    # Check in a future the next params for better performance. It seems it's failing due some incompatible params.
    # ... -Dgallium-drivers=v3d,kmsro,vc4,zink,virgl
    meson --prefix /usr -Dgles1=disabled -Dgles2=enabled -Dplatforms=x11 -Dvulkan-drivers=broadcom -Ddri-drivers= -Dgallium-drivers=v3d,kmsro,vc4,virgl -Dbuildtype=release -Dc_args="$EXTRA_PARAM" -Dcpp_args="$EXTRA_PARAM" build
    echo -e "\nCompiling... Estimated time on Raspberry Pi 4 over USB/SSD drive (Not overclocked): ~12 min. \n"
    time ninja -C build -j"$(nproc)"
    install
}

install_script_message
echo -e "\nVulkan installation.\n"
read -p "This process can't be undone. Continue? (Y/n) " response
if [[ $response =~ [Nn] ]]; then
    exit_message
fi
upgrade_dist
compile
exit_message
