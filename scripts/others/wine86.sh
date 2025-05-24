#!/bin/bash
#
# Description : Winex86 + Box86
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.2.1 (28/Sep/24)
# Tested      : Raspberry Pi 5
# Info        : https://github.com/ptitSeb/box86/blob/master/docs/X86WINE.md
#
# shellcheck source=../helper.sh
. ../helper.sh || . ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly COMPILE_PATH="$HOME/sc"
readonly HANGOVER_LASTEST_VERSION="9.17"
readonly PACKAGES_DEV=(libx11-dev)
readonly HANGOVER_BIN_URL="https://github.com/AndreRH/hangover/releases/download/hangover-${HANGOVER_LASTEST_VERSION}/hangover_${HANGOVER_LASTEST_VERSION}_debian12_bookworm_arm64.tar"
readonly WINETRICKS_URL="https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks"

remove_files() {
    sudo apt remove -y wine* hangover-wine
    sudo rm -rf ~/wine ~/.wine /usr/local/bin/wine /usr/local/bin/wineboot /usr/local/bin/winecfg /usr/local/bin/wineserver /usr/local/bin/winetricks ~/.local/share/applications/winetricks.desktop
}

uninstall() {
    read -p "Do you want to uninstall Wine and all its components (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e /usr/local/bin/wine ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -e /usr/local/bin/wine ]] || [[ -e /usr/bin/wine ]]; then
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

    echo -e "\nDone!. You can run it typing winetricks on a terminal or going to Menu > Accesories > Winetricks.\nCase of use on terminal: BOX86_NOBANNER=1 winetricks -q corefonts vcrun2010 dotnet20sp1"
}

install_winex86() {
    cd || exit 1

    wbranch="staging" #example: devel, staging (wine-staging 4.5+ requires libfaudio0:i386 - see below)
    wversion="9.16"
    wid="debian"
    wdist=$(get_OS_version_codename)
    wtag="-1"

    if [[ -e /usr/local/bin/wineserver ]]; then
        echo -e "\nClean up any old wine instances\n"
        wineserver -k
        rm -rf ~/.cache/wine                    # remove old wine-mono/wine-gecko install files
        rm -rf ~/.local/share/applications/wine # remove old program shortcuts
    fi

    echo -e "\nBackup any old wine installations..."
    [[ -e ~/wine ]] && sudo mv ~/wine ~/wine-old
    [[ -e ~/.wine ]] && sudo mv ~/.wine ~/.wine-old
    [[ -e /usr/local/bin/wine ]] && sudo mv /usr/local/bin/wine /usr/local/bin/wine-old
    [[ -e /usr/local/bin/wineboot ]] && sudo mv /usr/local/bin/wineboot /usr/local/bin/wineboot-old
    [[ -e /usr/local/bin/winecfg ]] && sudo mv /usr/local/bin/winecfg /usr/local/bin/winecfg-old
    [[ -e /usr/local/bin/wineserver ]] && sudo mv /usr/local/bin/wineserver /usr/local/bin/wineserver-old

    echo -e "\nDownload, extract wine, and install wine...\n"
    cd ~/Downloads || exit 1
    mkdir -p wine-installer || exit 1
    mkdir -p ~/wine || exit 1
    # https://dl.winehq.org/wine-builds/debian/dists/bookworm/main/binary-i386/?C=M;O=D
    wget "https://dl.winehq.org/wine-builds/${wid}/dists/${wdist}/main/binary-i386/wine-${wbranch}-i386_${wversion}~${wdist}${wtag}_i386.deb"
    wget "https://dl.winehq.org/wine-builds/${wid}/dists/${wdist}/main/binary-i386/wine-${wbranch}_${wversion}~${wdist}${wtag}_i386.deb"
    dpkg-deb -x "wine-${wbranch}-i386_${wversion}~${wdist}${wtag}_i386.deb" wine-installer
    dpkg-deb -x "wine-${wbranch}_${wversion}~${wdist}${wtag}_i386.deb" wine-installer
    mv wine-installer/opt/wine-devel/* ~/wine # install
    rm wine*.deb                              # clean up
    rm -rf wine-installer                     # clean up

    if [[ ! -e $HOME/wine/bin/wine ]]; then
        echo -e "I hate when this happens. I could not find the binary, so something was wrong."
        exit_message
    fi

    echo -e "\nInstall shortcuts...\n"
    # Create a script to launch wine programs as 32bit only
    echo -e '#!/usr/bin/env bash\nsetarch linux32 -L '"$HOME/wine/bin/wine "'"$@"' | sudo tee -a /usr/local/bin/wine >/dev/null
    #sudo ln -s ~/wine/bin/wine /usr/local/bin/wine # You could aslo just make a symlink, but box86 only works for 32bit apps at the moment
    sudo ln -s ~/wine/bin/wineboot /usr/local/bin/wineboot
    sudo ln -s ~/wine/bin/winecfg /usr/local/bin/winecfg
    sudo ln -s ~/wine/bin/wineserver /usr/local/bin/wineserver
    sudo chmod +x /usr/local/bin/wine /usr/local/bin/wineboot /usr/local/bin/winecfg /usr/local/bin/wineserver

    # These packages are needed for running wine-staging on RPiOS (Credits: chills340)
    sudo apt install libstb0 -y
    cd ~/Downloads || exit 1
    # libfaudio0_24.06+dfsg-1_arm64.deb
    wget -r -l1 -np -nd -A "libfaudio0_*~bpo10+1_i386.deb" http://ftp.us.debian.org/debian/pool/main/f/faudio/
    dpkg-deb -xv libfaudio0_*~bpo10+1_i386.deb libfaudio
    sudo cp -TRv libfaudio/usr/ /usr/
    rm libfaudio0_*~bpo10+1_i386.deb && rm -rf libfaudio
}

install_hangover() {
    echo -e "\nInstalling Hangover..."
    download_and_extract "$HANGOVER_BIN_URL" "/tmp"
    sudo chown _apt /tmp/hangover*
    sudo dpkg -i /tmp/hangover-wine_*
    [[ -e /usr/bin/wine ]] && sudo rm -rf /tmp/hangover-wine_*
    # wine needs add to /boot/firmware/config.txt: kernel=kernel8.img
}

install() {
    if is_kernel_64_bits; then
        install_hangover
    else
        compile_box86_or_64
        install_winex86
    fi
    install_winetricks
    enable_4k_pagesize
    echo -e "\nDone!. You can run it typing wine <app>.exe on a terminal\n"
    exit_message
}

install_script_message
echo "
Wine
====

 · For armhf: Compile & install latest Box86/Box64 + Wine.
 · For aarch64: Install Hangover v${HANGOVER_LASTEST_VERSION}.
 · Add Winetricks (Menu > Accesories).
 · Use wine <app>.exe or winecfg to configure Wine.
"

read -p "Press [Enter] to continue or [CTRL] + C to abort..."

install
