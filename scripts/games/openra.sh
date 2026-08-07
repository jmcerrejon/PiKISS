#!/bin/bash
#
# Description : OpenRA
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (12/Jul/26)
# Tested      : Raspberry Pi 5
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly PACKAGES=(libopenal1 liblua5.1-0 libvulkan1 libgles2 libsdl2-2.0-0 libfreetype6)
readonly PACKAGES_DEV=(git-all make g++ libopenal-dev libsdl2-dev libfreetype-dev liblua5.1-0-dev libvulkan-dev libgles-dev)
readonly BINARY_URL="https://raw.githubusercontent.com/jmcerrejon/pikiss-bin/main/games/openra-dev-rpi-aarch64.deb"
readonly OPENRA_BINARY_PATH="/usr/bin/openra-d2k"
readonly SOURCE_CODE_URL="https://github.com/OpenRA/OpenRA"

get_openra_install_path() {
    local INSTALL_PATH

    INSTALL_PATH=$(whereis openra | awk '{for (i = 2; i <= NF; i++) if ($i ~ /\/openra$/ && $i !~ /\/bin\// && $i !~ /\/games\//) { print $i; exit }}')
    if [[ -n $INSTALL_PATH ]]; then
        echo "$INSTALL_PATH"
        return
    fi

    if [[ -x $OPENRA_BINARY_PATH ]]; then
        dirname "$(readlink -f "$OPENRA_BINARY_PATH")"
    fi
}

runme() {
    if [[ ! -x $OPENRA_BINARY_PATH ]]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game Dune 2000..."
    "$OPENRA_BINARY_PATH"
    exit_message
}

uninstall() {
    local INSTALL_PATH

    read -p "Do you want to uninstall OpenRA (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        INSTALL_PATH=$(get_openra_install_path)
        sudo dpkg -r openra
        rm -rf "$HOME/.config/openra"
        if [[ -n $INSTALL_PATH ]] && [[ -e $INSTALL_PATH ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -x $OPENRA_BINARY_PATH ]]; then
    echo -e "OpenRA already installed.\n"
    uninstall
fi

install_dot_net() {
    echo -e "\nInstalling .NET 8 SDK, please wait..."
    wget -q https://dot.net/v1/dotnet-install.sh -O /tmp/dotnet-install.sh && chmod +x /tmp/dotnet-install.sh && /tmp/dotnet-install.sh --channel 8.0 --install-dir "$HOME/.dotnet"
}

compile() {
    local APP_DIR="$HOME/games/openra"

    install_packages_if_missing "${PACKAGES_DEV[@]}"
    install_dot_net
    export PATH="$HOME/.dotnet:$PATH"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    echo -e "\nCloning and compiling...\n"
    [[ ! -d "$HOME/sc/openra" ]] && git clone "$SOURCE_CODE_URL" openra
    cd "$HOME/sc/openra" || exit 1
    make DEPENDENCIES=system TARGETPLATFORM=linux-arm64
    echo -e "\nBuild successful. Installing to $APP_DIR..."
    mkdir -p "$APP_DIR"
    make install DESTDIR="" TARGETPLATFORM=linux-arm64 DEPENDENCIES=system gameinstalldir="$APP_DIR" prefix="$APP_DIR" bindir="$APP_DIR" datarootdir="$APP_DIR/share"
    echo -e "\nDone!."
    exit_message
}

install() {
    local INSTALL_PATH

    if ! is_userspace_64_bits; then
        echo -e "\nSorry, only 64-bit OS is supported."
        exit_message
    fi

    echo -e "\n\nInstalling OpenRA, please wait..."
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_install "$BINARY_URL"
    INSTALL_PATH=$(get_openra_install_path)
    echo -e "\nDone!. You can play Dune 2000 typing $OPENRA_BINARY_PATH or for more, opening the Menu > Games > OpenRA."
    runme
}

install_script_message
echo "
OpenRA for Raspberry Pi
=======================

 · Open-source engine for classic RTS games from the Command & Conquer saga.
 · This is a DEV_VERSION (compiled from main branch at 2026-07-12) for Raspberry Pi 5 (64-bit OS) with all latest changes and improvements, so it may not work properly.
 · On a Terminal, type openra-cnc (Command & Conquer: Tiberian Dawn) /openra-d2k (Dune 2000) /openra-ra (C&C Red Alert) for the specific game you want to play.
 · On a Terminal, you can also run the servers for each game by typing openra-cnc-server, openra-d2k-server or openra-ra-server. Refer to the official documentation for more information.
 · More info: $SOURCE_CODE_URL
"
read -p "Press [Enter] to continue..."

install
