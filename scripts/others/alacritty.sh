#!/bin/bash
#
# Description : Alacritty
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (09/Novp/20)
# Compatible  : Raspberry Pi 4 (tested)
# Repository  : https://github.com/alacritty/alacritty
#
. ../helper.sh || . ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/apps"
readonly PACKAGES_DEV=(cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev python3)
readonly BINARY_PATH="https://misapuntesde.com/rpi_share/alacritty-0.6.0-rpi.tar.gz"
readonly GITHUB_PATH="https://github.com/w23/alacritty"

runme() {
    if [ ! -f "$INSTALL_DIR/alacritty/alacritty" ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    echo
    read -p "Press [ENTER] to run..."
    cd "$INSTALL_DIR"/alacritty && ./alacritty
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/alacritty ~/.config/alacritty
}

uninstall() {
    read -p "Do you want to uninstall Alacritty (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e $INSTALL_DIR/alacritty/alacritty ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -e $INSTALL_DIR/alacritty/alacritty ]]; then
    echo -e "Alacritty already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nCreating shortcut icon..."
    if [[ ! -e ~/.local/share/applications/alacritty.desktop ]]; then
        cat <<EOF >~/.local/share/applications/alacritty.desktop
[Desktop Entry]
Name=Alacritty
Exec=${INSTALL_DIR}/alacritty/alacritty
Path=${INSTALL_DIR}/alacritty/
Icon=${INSTALL_DIR}/alacritty/icon.png
Type=Application
Comment=Alacritty is the fastest terminal emulator in existence. Using the GPU for rendering enables optimizations that simply aren't possible without it.
Categories=ConsoleOnly;Utility;System;
EOF
    fi
}

post_install() {
    cp -fr "$INSTALL_DIR/alacritty/.config/alacritty" ~/.config
}

install() {
    echo -e "\nInstalling, please wait...\n"
    download_and_extract "$BINARY_PATH" "$INSTALL_DIR"
    generate_icon
    post_install
    echo -e "\nDone!. App at $INSTALL_DIR/alacritty or Go to Menu > System Tools > Alacritty"
    runme
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"

    install_or_update_rust

    mkdir -p "$HOME/sc" && cd "$_"
    if [[ ! -d "$HOME/sc/alacritty" ]]; then
        echo -e "\nCloning and compiling repo...\n"
        git clone "$GITHUB_PATH" alacritty && cd "$_"
    else
        echo -e "\nDirectory already exists. Updating and compiling repo...\n"
        cd "$HOME/sc"
        git pull
    fi
    echo -e "\nEstimated Time on Raspberry Pi 4 (not overclocked): ~20 minutes (it's OK stopping long time at step 221/222)... \n"
    cargo build --release
    echo -e "\nDone!. You can found the app at $HOME/sc/alacritty/target/release"
    exit_message
}

install_script_message
echo "
Alacritty
=========

 · Alacritty is the fastest terminal emulator in existence.
 · The software is considered to be at a beta level of readiness, but it's already used by many as a daily driver.
 · This is a fork with OpenGL ES 2.0 support still not merged on the official repository.
 · Using the GPU for rendering enables optimizations that simply aren't possible without it.
 · I've used my own customization at ~/.config/alacritty/alacritty.yml. You can modify it following the next: https://github.com/alacritty/alacritty/wiki
 · This version is 0.6.0-dev (WIP). More info about version 0.5.0: https://blog.christianduerr.com/alacritty_0_5_0_announcement
 · More info about the PR at $GITHUB_PATH | https://github.com/alacritty/alacritty/pull/4373
"
read -p "Continue (Y/n)? " response

install
