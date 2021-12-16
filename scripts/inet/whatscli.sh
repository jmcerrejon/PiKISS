#!/bin/bash
#
# Description : Whatscli
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.1 (15/Dec/21)
# Compatible  : Raspberry Pi 1-4
# Repository  : https://github.com/normen/whatscli
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/apps"
readonly BINARY_URL="https://github.com/normen/whatscli/releases/download/v1.0.11/whatscli-v1.0.11-raspberrypi.zip"
readonly SOURCE_PATH="https://github.com/normen/whatscli"
readonly PIKISS_PATH="$PWD"

runme() {
    read -p "Press [ENTER] to run..."
    cd "$INSTALL_DIR"/whatscli && ./whatscli
    echo
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/whatscli ~/.config/whatscli ~/.local/share/applications/whatscli.desktop
}

uninstall() {
    read -p "Do you want to uninstall Whatscli (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/whatscli ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/whatscli ]]; then
    echo -e "Whatscli already installed.\n"
    uninstall
    exit 0
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    cp -f "$PIKISS_PATH/res/whatscli-icon.png" "$INSTALL_DIR"/whatscli
    if [[ ! -e ~/.local/share/applications/whatscli.desktop ]]; then
        cat <<EOF >~/.local/share/applications/whatscli.desktop
[Desktop Entry]
Name=Whatscli
Exec=${INSTALL_DIR}/whatscli/whatscli
Icon=${INSTALL_DIR}/whatscli/whatscli-icon.png
Path=${INSTALL_DIR}/whatscli/
Type=Application
Comment=i386 version of software platform used for teleconferencing using Box86
Categories=Network;
Terminal=true
EOF
    fi
}

install() {
    echo -e "\nInstalling, please wait..."
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"/whatscli
    generate_icon
    echo -e "\nDone!. Type $INSTALL_DIR/whatscli/whatscli or Go to Menu > Internet > Whatscli.\n"
    runme
}

install_script_message
echo "
Whatscli for Raspberry Pi
=========================

 · A command line interface for Whatsapp, based on go-whatsapp and tview.
 · Scan the QR code with WhatsApp on your phone (RESIZE SHELL OR CHANGE FONT SIZE to see whole code)
 · More info: $SOURCE_PATH
 · Things that work:

   - Sending and receiving WhatsApp messages in a command line app.
   - Connects through the Web App API without a browser.
   - Uses QR code for simple setup.
   - Allows downloading and opening image/video/audio/document attachments.
   - Allows sending documents.
   - Allows color customization.
   - Allows basic group management.
   - Supports desktop notifications.
"
install
