#!/bin/bash
#
# Description : RetroArch
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Contrib     : foxhound311, Rak1ta
# Version     : 1.0.16 (10/Mar/23)
#
# Help        : https://archive.org/download/RetroArch-rpi4 | https://archive.org/details/rpi4_64bit_retroarch
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly VERSION="1.15.0-1"
readonly INSTALL_DIR="/usr/local/bin"
readonly CONFIG_PATH="$HOME/.config/retroarch"
readonly PACKAGES=(libfreeimage3 libpugixml1v5)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/retroarch/retroarch-rpi4_${VERSION}_armhf.deb"
readonly BINARY_BUSTER_URL="https://misapuntesde.com/rpi_share/retroarch/retroarch-rpi4_1.11.1-1-buster_armhf.deb"
readonly BINARY_64_BITS_URL="https://misapuntesde.com/rpi_share/retroarch/retroarch-rpi4_${VERSION}_arm64.deb"
readonly CONFIG_URL="https://misapuntesde.com/rpi_share/retroarch/retroarch_config.tar.gz"
readonly CORES_URL="https://misapuntesde.com/rpi_share/retroarch/libretro_cores.tar.gz"
readonly CORES_64_BITS_URL="https://misapuntesde.com/rpi_share/retroarch/libretro_cores_64.tar.gz"
readonly BIOS_URL="https://misapuntesde.com/rpi_share/retroarch/libretro_bios.tar.gz"
readonly SYSTEM_URL="https://misapuntesde.com/rpi_share/retroarch/retroarch_system.zip"
readonly ASSETS_URL="https://buildbot.libretro.com/assets/frontend/assets.zip"
readonly AUTOCONFIG_URL="https://buildbot.libretro.com/assets/frontend/autoconfig.zip"
readonly DATABASE_URL="https://buildbot.libretro.com/assets/frontend/database-rdb.zip"
readonly OVERLAY_URL="https://buildbot.libretro.com/assets/frontend/overlays.zip"
readonly EMULATIONSTATIONDE_32_URL="https://gitlab.com/leonstyhre/emulationstation-de/-/package_files/25023905/download"
readonly EMULATIONSTATIONDE_64_URL="https://gitlab.com/leonstyhre/emulationstation-de/-/package_files/25023885/download"

runme() {
    echo
    if [[ ! -f $INSTALL_DIR/retroarch ]]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run..."
    "$INSTALL_DIR/retroarch"
    exit_message
}

uninstall() {
    read -p "Do you want to uninstall RetroArch (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        [[ -d $CONFIG_PATH ]] && rm -rf "$CONFIG_PATH"
        sudo apt remove -y retroarch-rpi4
        if [[ -e $INSTALL_DIR/retroarch ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -e $INSTALL_DIR/retroarch ]]; then
    echo -e "RetroArch already installed.\n"
    uninstall
fi

compile_doslib_repository() {
    [[ -f $DOSLIB_PATH/lnkdos16 ]] && return 0
    echo -e "Compiling file lnkdos16..."
    mkdir -p "$HOME/sc" && cd "$_" || return 0
    git clone "$SOURCE_CODE_DOSLIB_URL" doslib && cd "$_"/tool/linker/ || return 0
    make
}

compile() {
    [[ -e $HOME/sc/retroarch ]] && rm -rf "$HOME/sc/retroarch"
    compile_doslib_repository
    mkdir -p "$HOME/sc" && cd "$_" || return 0
    git clone "$SOURCE_CODE_URL" retroarch && cd "$_" || return 0
    mkdir -p "$HOME/sc/retroarch/bin"
    PATH=$PATH:$DOSLIB_PATH ./autogen.sh
    PATH=$PATH:$DOSLIB_PATH ./configure --enable-core-inline --enable-debug=heavy --prefix="$HOME/sc/retroarch/bin" --enable-sdl2 --enable-silent-rules --enable-scaler-full-line --disable-dependency-tracking --disable-sdl2test --disable-alsatest --disable-printer --disable-screenshots --host=arm-raspberry-linux-gnueabihf || exit 1
    echo -e "\nCompiling... It can takes ~14 minutes on RPi 4."
    make_with_all_cores
    echo -e "\nDone!. Check the code at $HOME/sc/retroarch"
    exit_message
}

install_config() {
    echo -e "\nInstalling config..."
    download_and_extract "$CONFIG_URL" "$HOME/.config"
}

install_system() {
    echo -e "\nInstalling system..."
    download_and_extract "$SYSTEM_URL" "$CONFIG_PATH"
}

install_cores() {
    local CORES_URL_INSTALL=$CORES_URL

    echo -e "\nInstalling cores..."
    if is_userspace_64_bits; then
        CORES_URL_INSTALL=$CORES_64_BITS_URL
    fi
    download_and_extract "$CORES_URL_INSTALL" "$CONFIG_PATH"
    echo -e "\nCores installed:\n"
    cd "$CONFIG_PATH/cores/" || return 0
    ls ./*.so --format=comma
    echo
}

install_bios() {
    echo "
======================
= BiOS for emulators =
======================

WARNING!: You need the BiOS files for some emulators (In some countries the laws may consider it pirate software).
"
    read -p "Do you want to download? (y/N) " response
    if [[ $response =~ [Yy] ]]; then
        download_and_extract "$BIOS_URL" "$CONFIG_PATH"
    fi
}

install_assets() {
    echo -e "\nInstalling assets..."
    download_and_extract "$ASSETS_URL" "$CONFIG_PATH/assets"
    echo -e "\nInstalling autoconfig..."
    download_and_extract "$AUTOCONFIG_URL" "$CONFIG_PATH/autoconfig"
    echo -e "\nInstalling database..."
    download_and_extract "$DATABASE_URL" "$CONFIG_PATH/database"
    echo -e "\nInstalling overlay..."
    download_and_extract "$OVERLAY_URL" "$CONFIG_PATH/overlay"
}

install() {
    local BINARY_URL_INSTALL=$BINARY_URL
    local CODENAME
    CODENAME=$(get_codename)

    echo -e "Installing package and dependencies..."

    if is_userspace_64_bits; then
        BINARY_URL_INSTALL=$BINARY_64_BITS_URL
    fi

    if [[ $CODENAME == "buster" ]]; then
        BINARY_URL_INSTALL=$BINARY_BUSTER_URL
    fi

    download_and_install "$BINARY_URL_INSTALL"
    install_config
    install_assets
    install_system
    install_cores
    install_bios
    echo -e "\nDone!. To play, use the Menu option on Games > RetroArch or type $INSTALL_DIR/retroarch"
    echo -e "NOTE: The icon in the Menu appears after reboot."
    runme
}

install_script_message
echo "
RetroArch
=========

· Thanks to Foxhound311.
· Version $VERSION
· Can be used with GLES, GLES3 or Vulkan drivers.
· All cores and binaries optimized for Raspberry Pi 4.
· Cores are the most updated versions. Anyway, online updater is disabled.
· Thanks @foxhound311 for compile all cores and binary files, he put so much effort into it :)
· KEYS: F=Full screen | F1=Quick menu | F2=Save game | F3=Show FPS | F4=Load game | F5=Desktop menu | F6/F7=Choose save slot | F8=Save screenshot
"

install
