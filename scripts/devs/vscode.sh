#!/bin/bash
#
# Description : VSCode
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.2.0 (28/Feb/21)
# Compatible  : Raspberry Pi 4 (tested)
# Help        : https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_URL="https://aka.ms/linux-armhf-deb"
readonly INSTALL_64_BITS_URL="https://aka.ms/linux-arm64-deb"
INPUT=/tmp/vscod.$$

install_essential_extensions_pack() {
    code --install-extension alefragnani.bookmarks
    code --install-extension coenraads.bracket-pair-colorizer-2
    code --install-extension naumovs.color-highlight
    code --install-extension equinusocio.vsc-community-material-theme
    code --install-extension mrmlnc.vscode-duplicate
    code --install-extension liamhammett.inline-parameters
    code --install-extension christian-kohler.path-intellisense
    code --install-extension foxundermoon.shell-format
    code --install-extension mads-hartmann.bash-ide-vscode
    code --install-extension timonwong.shellcheck
    code --install-extension tabnine.tabnine-vscode
    code --install-extension glavin001.unibeautify-vscode
}

post_install() {
    rm "$HOME"/code.deb
    lxpanelctl restart

    # Show code version
    get_vscode_installed_version

    # Ask to Install default extensions
    echo "Now you can choose to install the next extensions:

 · Bookmarks (alefragnani.bookmarks).
 · Bracket Pair Colorizer 2 (coenraads.bracket-pair-colorizer-2).
 · Color Highlight (naumovs.color-highlight).
 · Community Material Theme (equinusocio.vsc-community-material-theme).
 · Duplicate action (mrmlnc.vscode-duplicate).
 · Inline Parameters for VSCode (liamhammett.inline-parameters).
 · Path Intellisense (christian-kohler.path-intellisense).
 · shell-format (foxundermoon.shell-format).
 · shellcheck (timonwong.shellcheck).
 · Bash IDE (mads-hartmann.bash-ide-vscode).
 · TabNine (tabnine.tabnine-vscode).
 · Unibeautify - Universal Formatter (glavin001.unibeautify-vscode).
"
    read -p "Do you want to install those extensions (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        install_essential_extensions_pack
    fi
}

# VSCode

uninstall_vscode() {
    if [[ ! -f /usr/bin/code ]]; then
        return 0
    fi
    echo -e "VSCode already installed."
    read -p "Do you want to uninstall VSCode (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo apt remove -y code/now && rm -rf ~/.vscode ~/.config/Code/
        if [[ -e ~/.config/Code/ ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

get_vscode_installed_version() {
    local VSCODE_VERSION
    VSCODE_VERSION=$(code --version 2>&1 | head -n 1)
    echo -e "\nVersion installed: $VSCODE_VERSION\n"
}

install_vscode() {
    uninstall_vscode
    install_script_message
    echo "
VSCode for Raspberry Pi
=======================

 · Get the latest version from Microsoft's website (not using or adding source list repository).
 · 32 or 64 bits.
 · ~220 Mb occupied with no extensions.
 · Ask if you want to install what I considered essential extensions, cause I'm a cool dev :)
"
    read -p "Press [Enter] to continue..."

    local VSCODE_INSTALL

    echo -e "\nInstalling, please wait...\n"

    if ! is_kernel_64_bits; then
        VSCODE_INSTALL="$INSTALL_URL"
    else
        VSCODE_INSTALL="$INSTALL_64_BITS_URL"
    fi
    wget -q --show-progress "$VSCODE_INSTALL" -O "$HOME"/code.deb
    echo
    sudo dpkg -i "$HOME"/code.deb
    post_install
    echo -e "\nVSCode installed!. Go to Menu > Programming > Visual Studio Code or type code on a terminal."
    exit_message
}

# VSCodium

uninstall_vscodium() {
    if [[ ! -f /usr/bin/codium ]]; then
        return 0
    fi
    echo -e "VSCodium already installed."
    read -p "Do you want to uninstall it (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo apt remove -y codium && rm -rf ~/.config/VSCodium/
        sudo rm /etc/apt/sources.list.d/vscodium.list /etc/apt/trusted.gpg.d/vscodium-archive-keyring.gpg
        if [[ -e ~/.config/VSCodium/ ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

add_repo_vscodium() {
    echo -e "Adding PHP & new repository /etc/apt/sources.list.d/vscodium.list..."
    wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg |
        gpg --dearmor |
        sudo dd of=/etc/apt/trusted.gpg.d/vscodium-archive-keyring.gpg
    echo 'deb [signed-by=/etc/apt/trusted.gpg.d/vscodium-archive-keyring.gpg] https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs/ vscodium main' |
        sudo tee /etc/apt/sources.list.d/vscodium.list
    sudo apt update
}

install_vscodium() {
    uninstall_vscodium
    install_script_message
    echo "
VSCodium for Raspberry Pi
=========================

 · Get the latest version of VSCode removing the Telemetry.
 · Add /etc/apt/sources.list.d/vscodium.list for future updates (If you uninstall VSCodium with PiKISS the repo is removed, too).
 · 32 or 64 bits.
 · ~220 Mb occupied with no extensions.
"
    read -p "Press [Enter] to continue..."

    echo -e "\nInstalling, please wait...\n"
    add_repo_vscodium
    sudo apt install -y codium
    echo -e "\nVSCodium installed!. Go to Menu > Programming > VSCodium or type codium on a terminal."
    exit_message
}

menu() {
    while true; do
        dialog --clear \
            --title "[ VSCode/ium ]" \
            --menu "Choose IDE:" 11 100 3 \
            VSCodium "Free/Libre Open Source Software Binaries of VSCode" \
            VSCode "VSCode is a freeware source-code editor made by Microsoft " \
            Exit "Back to main menu" 2>"${INPUT}"

        menuitem=$(<"${INPUT}")

        case $menuitem in
        VSCodium) clear && install_vscodium && return 0 ;;
        VSCode) clear && install_vscode && return 0 ;;
        Exit) exit 0 ;;
        esac
    done
}

menu
