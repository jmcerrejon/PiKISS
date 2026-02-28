#!/bin/bash
#
# Description : Hangover Wine for ARM64
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.3.0 (28/Feb/26)
# Tested      : Raspberry Pi 5
# Info        : https://github.com/AndreRH/hangover
#
# shellcheck source=../helper.sh
. ../helper.sh || . ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly COMPILE_PATH="$HOME/sc"
readonly HANGOVER_LASTEST_VERSION="11.0"
readonly PACKAGES_DEV=(libx11-dev)
readonly HANGOVER_BIN_URL="https://github.com/AndreRH/hangover/releases/download/hangover-${HANGOVER_LASTEST_VERSION}/hangover_${HANGOVER_LASTEST_VERSION}_debian13_trixie_arm64.tar"
readonly HANGOVER_DLL_URL="https://github.com/AndreRH/hangover/releases/download/hangover-${HANGOVER_LASTEST_VERSION}/hangover_${HANGOVER_LASTEST_VERSION}_dlls.tar"
readonly WINETRICKS_URL="https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks"

uninstall() {
    read -p "Do you want to uninstall Wine and all its components (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
            sudo apt remove -y wine* hangover*
            sudo rm -rf ~/wine ~/.wine /usr/local/bin/wine /usr/local/bin/wineboot /usr/local/bin/winecfg /usr/local/bin/wineserver /usr/local/bin/winetricks ~/.local/share/applications/winetricks.desktop ~/.local/share/applications/wine*
        if [[ -e /usr/bin/wine ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -e /usr/bin/wine ]]; then
    echo -e "Wine already installed.\n"
    uninstall
fi

generate_icon_winetricks() {
    if [[ ! -e /usr/local/bin/winetricks ]]; then
        return 0
    fi

    echo -e "\nGenerating icon...\n"
    if [[ ! -e ~/.local/share/applications/winetricks.desktop ]]; then
        cat <<EOF >~/.local/share/applications/winetricks.desktop
[Desktop Entry]
Name=Winetricks
Comment=Work around problems and install applications under Wine
Exec=env BOX86_NOBANNER=1 winetricks --gui
Terminal=false
Icon=B13E_wscript.0
Type=Application
Categories=Utility;
EOF
    fi
}

enable_4k_pagesize() {
    local CONFIG_PATH="/boot/firmware/config.txt"

    if [[ $(getconf PAGESIZE) -eq 4096 ]]; then
        return 0
    fi
    if grep -q "kernel=kernel8.img" $CONFIG_PATH; then
        return 0
    fi
    echo "
WARNING!
========

· Wine doesn't work with 16K Kernel PageSize.
· You need to switch to the 4k pagesize kernel.
· Add to $CONFIG_PATH: kernel=kernel8.img
"
    read -p "Can I modify the $CONFIG_PATH file by adding this setting? (y/N) " response
    if [[ $response =~ [Yy] ]]; then
        if ! grep -q "kernel=kernel8.img" $CONFIG_PATH; then
            echo -e "\nkernel=kernel8.img" | sudo tee -a $CONFIG_PATH
            read -p "Remember you need to reboot for changes to take effect."
        fi
    fi
}

install_winetricks() {
    echo -e "\nInstalling some essential components for you (cabextract, winetricks)...\n"
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq libstb0 cabextract </dev/null >/dev/null

    wget -q "$WINETRICKS_URL"
    sudo chmod +x winetricks && sudo mv winetricks /usr/local/bin/
    generate_icon_winetricks

    echo -e "\nDone!. You can run it typing winetricks on a terminal or going to Menu > Accesories > Winetricks.\nCase of use on terminal: winetricks -q corefonts vcrun2010 dotnet20sp1"
}

install_hangover() {
    echo -e "\nInstalling Hangover..."
    download_and_extract "$HANGOVER_BIN_URL" "/tmp"
    sudo apt install -y libodbc2 libasound2-plugins cabextract
    sudo chown _apt /tmp/hangover*
    sudo dpkg -i /tmp/hangover*.deb
    [[ -e /usr/bin/wine ]] && sudo rm -rf /tmp/hangover*
    # wine needs add to /boot/firmware/config.txt: kernel=kernel8.img
    wine reg.exe add HKCU\\Software\\Wine\\Drivers /v Graphics /d wayland,x11
}

install() {
    if ! is_kernel_64_bits; then
        echo -e "\nThis script only supports ARM64 systems."
        exit_message
    fi

    install_hangover
    install_winetricks
    enable_4k_pagesize
    echo -e "\nDone!. You can run it typing wine <app>.exe on a terminal\n"
    exit_message
}

install_script_message
echo "
Wine (Hangover)
===============

 · Install Hangover v${HANGOVER_LASTEST_VERSION} for aarch64 kernel (RPiOS 64-bit).
 · Add Winetricks (Menu > Accesories).
 · Use wine <app>.exe or winecfg to configure Wine.
 · ARM64 only.
"

read -p "Press [Enter] to continue or [CTRL] + C to abort..."

install
