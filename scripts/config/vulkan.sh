#!/bin/bash
#
# Description : Vulkan driver
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 2.0.0 (24/May/25)
# Tested      : Raspberry Pi 5
#
# Help        : https://ninja-build.org/manual.html#ref_pool
#             : https://qengineering.eu/install-vulkan-on-raspberry-pi.html
#             : https://blogs.igalia.com/apinheiro/2020/06/v3dv-quick-guide-to-build-and-run-some-demos/
#

# Enable strict error handling
set -euo pipefail

# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/mesa_vulkan"
readonly SOURCE_CODE_URL="https://gitlab.freedesktop.org/mesa/mesa.git"
readonly LIB_DRM_VERSION="2.4.124" # Get the latest version at https://dri.freedesktop.org/libdrm/?C=M;O=D
readonly VULKAN_INSTALL_SCRIPT_URL="https://gist.githubusercontent.com/jmcerrejon/a08eca2bba3e5e23bda2b3f7d7506ab0/raw/11aad2190e1244821571788c4b143c6970f476e0/reinstall-vulkan-driver.sh"
readonly LOG_FILE="/tmp/vulkan_install_$(date +%Y%m%d_%H%M%S).log"
readonly BACKUP_DIR="$HOME/.vulkan_backup_$(date +%Y%m%d_%H%M%S)"
PI_VERSION_NUMBER=$(get_pi_version_number)
BRANCH_VERSION="mesa-25.1.1"
INPUT=/tmp/vulkan.$$

log_message() {
    local level="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_FILE"
}

error_exit() {
    log_message "ERROR" "$1"
    exit 1
}

get_optimal_build_params() {
    local cpu_cores
    local cc_args
    local cpp_args
    local link_args=""
    local memory_gb

    cpu_cores=$(nproc)
    memory_gb=$(free -g | awk '/^Mem:/{print $2}')

    if is_userspace_64_bits; then
        cc_args="-mcpu=cortex-a72 -O3 -DNDEBUG -pipe"
        cpp_args="-mcpu=cortex-a72 -O3 -DNDEBUG -pipe"
        # Enable LTO for better performance on 64-bit with sufficient memory
        if [[ $memory_gb -ge 6 ]]; then
            cc_args="$cc_args -flto"
            cpp_args="$cpp_args -flto"
            link_args="-flto"
        fi
    else
        cc_args="-mcpu=cortex-a72 -mfpu=neon-fp-armv8 -O3 -DNDEBUG -pipe"
        cpp_args="-mcpu=cortex-a72 -mfpu=neon-fp-armv8 -O3 -DNDEBUG -pipe"
    fi

    echo "$cpu_cores|$cc_args|$cpp_args|$link_args"
}

install() {
    log_message "INFO" "Installing compiled Vulkan driver..."
    cd "$INSTALL_DIR" || error_exit "Failed to enter install directory"

    sudo ninja -C build install || error_exit "Failed to install Vulkan driver"

    sudo ldconfig

    if command -v glxinfo &>/dev/null; then
        log_message "INFO" "Verifying OpenGL information:"
        glxinfo -B
    fi

    if command -v vulkaninfo &>/dev/null; then
        log_message "INFO" "Verifying Vulkan installation:"
        vulkaninfo --summary 2>/dev/null || log_message "WARN" "Vulkan verification failed"
    fi

    log_message "INFO" "Vulkan driver installation completed successfully"
    echo "Done."
    exit_message
}

install_full_deps() {
    log_message "INFO" "Installing dependencies..."

    sudo apt-get update || error_exit "Failed to update package cache"

    local essential_deps=(
        build-essential git cmake ninja-build python3-pip python3-mako
        pkg-config bison flex libssl-dev libgnutls28-dev
        libdrm-dev libelf-dev mesa-utils zlib1g-dev
        libexpat1-dev libxml2-dev libzstd-dev python3-yaml
    )

    local display_deps=(
        libxcb-randr0-dev libxrandr-dev libxcb-xinerama0-dev libxinerama-dev
        libxcursor-dev libxcb-cursor-dev libxkbcommon-dev xutils-dev
        libpthread-stubs0-dev libpciaccess-dev libffi-dev x11proto-xext-dev
        libxcb1-dev libxcb-*dev libx11-dev libxcb-glx0-dev libx11-xcb-dev
        libxext-dev libxdamage-dev libxfixes-dev libva-dev x11proto-randr-dev
        x11proto-present-dev libxshmfence-dev libxxf86vm-dev
        libwayland-dev wayland-protocols libwayland-egl-backend-dev
    )

    local vulkan_deps=(
        libvulkan-dev libvulkan1 libassimp-dev
        libdrm-dev libdrm2 libdrm-common
    )

    for deps_array in essential_deps display_deps vulkan_deps; do
        local -n deps_ref="$deps_array"
        log_message "INFO" "Installing ${deps_array} dependencies..."
        sudo apt-get install -y "${deps_ref[@]}" || error_exit "Failed to install ${deps_array}"
    done

    if is_userspace_64_bits; then
        sudo apt install -y libclc-16-dev || sudo apt install -y libclc-dev
    else
        sudo apt install -y libclc-dev
    fi

    install_meson
    log_message "INFO" "Dependencies installation completed"
}

clone_repo() {
    echo
    log_message "INFO" "Cloning mesa repository..."
    cd "$HOME" || error_exit "Failed to navigate to home directory"

    if [[ -d "$INSTALL_DIR" ]]; then
        log_message "INFO" "Removing existing mesa directory..."
        rm -rf "$INSTALL_DIR"
    fi

    git clone -b "$BRANCH_VERSION" --depth=1 "$SOURCE_CODE_URL" "$INSTALL_DIR" || error_exit "Failed to clone mesa repository"
    cd "$INSTALL_DIR" || error_exit "Failed to enter mesa directory"
    log_message "INFO" "Repository cloned successfully"
}

install_vulkan_from_official_repository() {
    local CODENAME
    CODENAME=$(get_codename)

    if [ "$CODENAME" != "bullseye" ] && [ "$CODENAME" != "bookworm" ]; then
        log_message "ERROR" "You need at least Debian Bullseye to install Vulkan. See: https://wiki.debian.org/bullseye"
        return 0
    fi

    log_message "INFO" "Installing Vulkan driver from official repository..."
    sudo apt install -y mesa-vulkan-drivers libvulkan-dev libvulkan1 vulkan-tools || error_exit "Failed to install Vulkan from repository"

    # Verify installation
    if command -v glxinfo &>/dev/null; then
        glxinfo -B
    fi

    log_message "INFO" "Official Vulkan installation completed successfully"
    echo "Done."
    exit_message
}

compile_and_install_libdrm() {
    local LIBDRM_URL
    local SOURCE_CODE_PATH
    local build_params
    local ninja_jobs
    local cc_args
    local cpp_args
    local link_args

    FILE_NAME="libdrm-$LIB_DRM_VERSION"
    LIBDRM_URL="https://dri.freedesktop.org/libdrm/$FILE_NAME.tar.xz"
    SOURCE_CODE_PATH="$HOME/sc"

    build_params=$(get_optimal_build_params)
    IFS='|' read -r ninja_jobs cc_args cpp_args link_args <<<"$build_params"

    log_message "INFO" "Compiling libdrm with optimizations..."
    download_and_extract "$LIBDRM_URL" "$SOURCE_CODE_PATH"
    cd "$FILE_NAME" || error_exit "Failed to enter libdrm directory"
    [[ ! -d build ]] && mkdir build
    cd build || error_exit "Failed to enter build directory"

    local libdrm_args=(
        --wipe
        --prefix=/usr
        --buildtype=release
        -Dudev=true
        -Dvc4=enabled
        -Dintel=disabled
        -Dvmwgfx=disabled
        -Dradeon=disabled
        -Damdgpu=disabled
        -Dnouveau=disabled
        -Dfreedreno=disabled
        -Dinstall-test-programs=true
        -Dc_args="$cc_args"
        -Dcpp_args="$cpp_args"
    )

    if [[ -n "$link_args" ]]; then
        libdrm_args+=(-Dc_link_args="$link_args" -Dcpp_link_args="$link_args")
    fi

    meson setup "${libdrm_args[@]}" .. || error_exit "Failed to configure libdrm build"
    time ninja -C . -j"$ninja_jobs" || error_exit "Failed to compile libdrm"
    sudo ninja install || error_exit "Failed to install libdrm"
    sudo ldconfig
    log_message "INFO" "libdrm compiled and installed successfully"
}

compile() {
    local build_params
    local ninja_jobs
    local cc_args
    local cpp_args
    local link_args

    log_message "INFO" "Starting Vulkan driver compilation process"

    clear
    read -p "WARNING! This operation could break your OS. Ensure you have a backup. Continue? (Y/n) " response
    if [[ $response =~ [nN] ]]; then
        exit_message
    fi

    build_params=$(get_optimal_build_params)
    IFS='|' read -r ninja_jobs cc_args cpp_args link_args <<<"$build_params"

    log_message "INFO" "Using $ninja_jobs parallel jobs for compilation"

    log_message "INFO" "Cleaning up previous builds..."
    [[ -d "$INSTALL_DIR" ]] && rm -rf "$INSTALL_DIR"
    sudo ldconfig

    install_full_deps
    compile_and_install_libdrm
    clone_repo

    [[ -d "$INSTALL_DIR"/build ]] && rm -rf "$INSTALL_DIR"/build

    export PKG_CONFIG_PATH="/usr/lib/aarch64-linux-gnu/pkgconfig:/usr/lib/arm-linux-gnueabihf/pkgconfig:/usr/share/pkgconfig:/usr/lib/pkgconfig"

    local meson_args=(
        --prefix /usr
        --buildtype=release
        -Dgles1=enabled
        -Dgles2=enabled
        -Dplatforms=x11,wayland
        -Dxlib-lease=auto
        -Dvulkan-drivers=broadcom
        -Dgallium-drivers=v3d,vc4,virgl,zink
        -Degl=enabled
        -Dglx=auto
        -Dllvm=disabled
        -Dvalgrind=disabled
        -Dbuild-tests=false
        -Dc_args="$cc_args"
        -Dcpp_args="$cpp_args"
    )

    if [[ -n "$link_args" ]]; then
        meson_args+=(-Dc_link_args="$link_args" -Dcpp_link_args="$link_args")
    fi

    log_message "INFO" "Configuring mesa build with meson..."
    meson setup "${meson_args[@]}" build || error_exit "Failed to configure mesa build"

    log_message "INFO" "Starting compilation with $ninja_jobs jobs..."
    time ninja -C build -j"$ninja_jobs" || error_exit "Compilation failed"

    install
}

menu_choose_branch() {
    while true; do
        dialog --clear \
            --title "[ Vulkan Branch ]" \
            --menu "Select from the list:" 11 100 3 \
            repo "(Recommended) Not latest but stable from official repository." \
            stable "Stable branch ${BRANCH_VERSION}. Install at your own risk." \
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

· Version: $BRANCH_VERSION with 32/64 bits support.
· This process can't be undone.
· Make sure you backup your data.
· This script installs/compiles libdrm & Vulkan Mesa Driver on your OS.
· Estimated compilation time on Raspberry Pi 5 ~14 min over USB/SSD drive (Not overclocked).
"
read -p "Continue? (Y/n) " response
if [[ $response =~ [Nn] ]]; then
    exit_message
fi

upgrade_dist
menu_choose_branch
exit_message
