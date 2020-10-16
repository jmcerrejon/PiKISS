#!/bin/bash
#
# Description : VSCode
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.2 (15/OCT/20)
# Compatible  : Raspberry Pi 4 (tested)
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_URL="https://aka.ms/linux-armhf-deb"
INSTALL_64_BITS_URL="https://aka.ms/linux-arm64-deb"

runme() {
    echo
    if [ ! -f /usr/bin/code ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the app..."
    code
    sleep 5
    exit_message
}

remove_files() {
    sudo apt remove -y code/now
    rm -rf ~/.vscode ~/.config/Code/
}

uninstall() {
    read -p "Do you want to uninstall VSCode (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/residualvm ]]; then
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

if [[ -f /usr/bin/code ]]; then
    echo -e "VSCode already installed."
    get_vscode_installed_version
    uninstall
    exit 0
fi

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

install() {
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
    echo -e "\nVSCode installed!. Go to Menu > Programming > Visual Studio Code or type code on terminal."
}

install_script_message
echo "
VSCode for Raspberry Pi
=======================

 · Get the latest version from Microsoft.
 · 32 or 64 bits.
 · ~220 Mb occupied with no extensions.
 · Ask if you want to install what I considered essential extensions, cause I'm a cool dev :)
"
read -p "Press [Enter] to continue..."

install
runme
