#!/bin/bash -e
#
# Description : Install and setup Zsh (Z shell)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (4/Jun/22)
# Compatible  : Raspberry Pi 4
#
# Help        : https://linuxhint.com/install-zsh-raspberry-pi/
#
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly PACKAGES=(zsh)
readonly ZSH_CONFIG_PATH="$HOME/.zsh"
readonly ZSH_CONFIG_FILE_PATH="$HOME/.zshrc"

uninstall() {
    local OH_MY_ZSH_UNINSTALL_SCRIPT_PATH="$HOME/.oh-my-zsh/tools/uninstall.sh"

    read -p "Do you want to uninstall ZSH (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$ZSH_CONFIG_FILE_PATH" "$ZSH_CONFIG_FILE_PATH" /home/pi/.zsh_history
        uninstall_packages "${PACKAGES[@]}"
        [[ -e $OH_MY_ZSH_UNINSTALL_SCRIPT_PATH ]] && source "$OH_MY_ZSH_UNINSTALL_SCRIPT_PATH"
    fi
    exit_message

}

if which zsh >/dev/null; then
    echo -e "ZSH already installed.\n"
    uninstall
fi

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    install_theme
}

install_theme() {
    mkdir -p "$ZSH_CONFIG_PATH"
    git clone https://github.com/sindresorhus/pure.git "$ZSH_CONFIG_PATH/pure"
    echo "fpath+=$ZSH_CONFIG_PATH/pure" >"$ZSH_CONFIG_FILE_PATH"
    autoload -U promptinit
    promptinit
    prompt pure
}

install_script_message
echo "
Install and setup Zsh (Z shell)
===============================

· Default theme: pure. +info: https://github.com/sindresorhus/pure
· plugins: https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
· Wiki Oh My Zsh!: https://github.com/ohmyzsh/ohmyzsh/wiki
· You can safety uninstall later.
"
read -p "Continue? (Y/n) " response
if [[ $response =~ [Nn] ]]; then
    exit_message
fi
install
