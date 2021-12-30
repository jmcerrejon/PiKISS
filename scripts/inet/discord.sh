#!/bin/bash
#
# Description : Discord
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.5 (30/Dec/21)
# Compatible  : Raspberry Pi 4 (tested)
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

GO_INSTALL_PATH="/usr/local"
SOURCE_CODE_URL="https://github.com/Bios-Marcel/cordless"
PACKAGES=(xclip wl-clipboard feh)
GO_URL="https://golang.org/dl/go1.14.6.linux-armv6l.tar.gz"

runme() {
    if [ ! -f ~/go/bin/cordless ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run Cordless..."
    ~/go/bin/cordless
    exit_message
}

uninstall() {
    read -p "Do you want to uninstall Cordless (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        # Remove unused packages
        sudo apt-get remove -y "${PACKAGES[@]}"
        # Remove files
        sudo rm -rf ~/go /usr/local/go ~/.local/share/applications/cordless.desktop ~/.config/cordless
        if [[ -e ~/go/bin/cordless ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    runme
}

if [[ -f ~/go/bin/cordless ]]; then
    echo -e "Cordless already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/cordless.desktop ]]; then
        cat <<EOF >~/.local/share/applications/cordless.desktop
[Desktop Entry]
Name=Cordless
Exec=${HOME}/go/bin/cordless
Path=${HOME}/go/bin/
Icon=terminal
Type=Application
Comment=Cordless is a custom Discord client that aims to have a low memory footprint and be aimed at power-users.
Categories=Network
Terminal=true
X-KeepTerminal=true
EOF
    fi
}

install_go() {
    if [[ -d /usr/local/go ]]; then
        echo -e "\nGo installed, moving on..."
        return 0
    fi

    echo -e "\nInstalling Go..."
    wget -q --show-progress -O /tmp/go.tar.gz "$GO_URL"
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz && rm /tmp/go.tar.gz
    echo
    /usr/local/go/bin/go version
}

install() {
    echo -e "\n\nInstalling Cordless, please wait..."
    install_packages_if_missing "${PACKAGES[@]}"
    install_go
    echo -e "\nDownloading Cordless...\n"
    export GO111MODULE=on && /usr/local/go/bin/go get -u "$SOURCE_CODE_URL"
    generate_icon
    echo -e "\nDone!. Go to Menu > Internet > Cordless or type ~/go/bin/cordless"
    runme
}

echo "Install Cordless"
echo "================"
echo
echo " · Cordless is a custom Discord client that aims to have a low memory footprint and be aimed at power-users."
echo " · Keyboard shortcut changer via Ctrl + K | Ctrl + C to Exit | "
echo " · Install path: ~/go/bin/cordless"

install
