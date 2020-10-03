#!/bin/bash
#
# Description : Zoom (using Box86)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.2 (03/Oct/20)
# Compatible  : Raspberry Pi 2-4 (tested)
# Repository  : https://github.com/ptitSeb/box86
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/apps"
readonly PACKAGES=( libxcb-xtest0 cmake )
readonly BINARY_URL="https://d11yldzmag5yn.cloudfront.net/prod/5.3.469451.0927/zoom_i686.tar.xz"
readonly BOX86_PATH="/usr/local/bin/box86"

runme() {
    read -p "Press [ENTER] to run..."
    cd "$INSTALL_DIR"/zoom && ./zoom-rpi.sh
    echo
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/zoom ~/.local/share/applications/zoom.desktop
}

uninstall() {
    read -p "Do you want to uninstall Zoom (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/zoom ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/zoom ]]; then
    echo -e "Zoom already installed.\n"
    uninstall
    exit 0
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    cp -f "$HOME"/piKiss/res/zoom-icon.png "$INSTALL_DIR"/zoom
    if [[ ! -e ~/.local/share/applications/zoom.desktop ]]; then
        cat <<EOF >~/.local/share/applications/zoom.desktop
[Desktop Entry]
Name=Zoom
Exec=${INSTALL_DIR}/zoom/zoom-rpi.sh
Icon=${INSTALL_DIR}/zoom/zoom-icon.png
Path=${INSTALL_DIR}/zoom/
Type=Application
Comment=i386 version of software platform used for teleconferencing using Box86
Categories=Network;
Terminal=true
EOF
    fi
}

make_run_script() {
    echo -e "\nMaking a cool script called zoom-rpi.sh..."
    cat <<EOF >${INSTALL_DIR}/zoom/zoom-rpi.sh
#!/bin/bash
if [ ! -f /usr/local/bin/box86 ]; then
    echo "Box86 missing, please install"
    exit 1
fi
box86 zoom
EOF
chmod +x "$INSTALL_DIR"/zoom/zoom-rpi.sh
}


install() {
    echo -e "\nInstalling, please wait..."
    installPackagesIfMissing "${PACKAGES[@]}"
    if [ ! -f $BOX86_PATH ]; then
        installBox86
    fi
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    make_run_script
    generate_icon
    echo -e "\nDone!. Type $INSTALL_DIR/zoom/zoom-rpi.sh or Go to Menu > Internet > Zoom.\n"
    runme
}

echo "
Zoom for Raspberry Pi
=====================

 · Using Box86 thanks to ptitSeb (https://github.com/ptitSeb/box86).
"

install