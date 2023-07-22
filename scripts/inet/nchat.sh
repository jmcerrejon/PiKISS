#!/bin/bash
#
# Description : nchat - ncurses chat is a terminal-based chat with support for Telegram and WhatsApp.
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 2.0.0 (22/Jul/23)
# Help        : https://github.com/d99kris/nchat#low-memory--ram-systems
#
# shellcheck source=../helper.sh
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/apps"
readonly BINARY_URL="$PIKISS_REMOTE_SHARE_DIR_URL/nchat-arm64.tar.gz"
readonly PACKAGES_DEV=(sudo apt install ccache cmake build-essential gperf help2man libreadline-dev libssl-dev libncurses-dev libncursesw5-dev ncurses-doc zlib1g-dev libsqlite3-dev libmagic-dev php-cli clang)
readonly SOURCE_CODE_URL="https://github.com/d99kris/nchat"

runme() {
    cd "$INSTALL_DIR"/nchat && ./nchat.sh
    echo
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/nchat ~/.nchat ~/.local/share/applications/nchat.desktop ~/.local/share/nchat
}

uninstall() {
    read -p "Do you want to uninstall nChat (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/nchat ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/nchat ]]; then
    echo -e "nChat already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/nchat.desktop ]]; then
        cat <<EOF >~/.local/share/applications/nchat.desktop
[Desktop Entry]
Name=nChat
Exec=${INSTALL_DIR}/nchat/nchat.sh
Icon=${INSTALL_DIR}/nchat/nchat.png
Path=${INSTALL_DIR}/nchat/
Type=Application
Comment=nchat is a terminal-based chat client for Linux and macOS with support for Telegram and WhatsApp.
Categories=Network;
Terminal=true
EOF
    fi
}

compile() {
    # BUG Check https://github.com/d99kris/nchat/issues/23
    echo -e "\nInstalling dependencies (if proceed)...\n"
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    install_go && export PATH=$PATH:/usr/local/go/bin
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    echo
    git clone "$SOURCE_CODE_URL" nchat && cd "$_" || exit 1
    mkdir -p build && cd build || exit 1
    CC=/usr/bin/clang CXX=/usr/bin/clang++ cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
    cmake --build . --target prepare_cross_compiling
    cd ../lib/tgchat/ext/td || exit 1
    php SplitSource.php
    cd - || exit 1
    echo -e "\n\nCompiling... Estimated time on RPi 4: ~1 hour.\n"
    time make -s -j"$(nproc)" || { echo -e "\nError at compile.\n"; exit 1; }
    read -p "Do you want to install nChat (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo make install
        echo -e "\nDone!. Run with: nchat\n"
    fi
}

install() {
    echo -e "\nInstalling, please wait..."
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR/nchat/share" || exit 1
    mv nchat ~/.local/share/
    generate_icon
    echo -e "\nDone!. Type $INSTALL_DIR/nchat/nchat.sh or Go to Menu > Internet > nChat.\n"
    runme
}

install_script_message
echo "
nChat for Raspberry Pi
======================

 · A Command Line Interface for Telegram & WhatsApp.
 · For 64 bits ATM.
 · More info & usage: $SOURCE_CODE_URL
 · Type nchat -s to configure your account.
"
install
