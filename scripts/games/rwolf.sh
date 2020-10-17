#!/bin/bash
#
# Description : Return to Castle Wolfenstein for Raspberry Pi
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.3.2 (17/Oct/20)
# Compatible  : Raspberry Pi 3-4 (tested)
#
source ../helper.sh || source ./scripts/helper.sh || source ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"
#PAK_FILE_SHARE="ftp://ftp.gr.freebsd.org/pub/vendors/idgames/idstuff/wolf/linux/wolfspdemo-linux-1.1b.x86.run"
BINARY_URL="https://misapuntesde.com/rpi_share/rtcw_bin-rpi.tar.gz"
DATA_URL=""

runme() {
    if [ ! -f "$INSTALL_DIR/rtcw/Main/pak0.pk3" ]; then
        exit_message
    fi
    if [ ! -f "$INSTALL_DIR/rtcw/iowolfsp.arm" ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run..."
    cd "$INSTALL_DIR"/rtcw && ./iowolfsp.arm
    exit_message
}

remove_files() {
    [[ -d "$INSTALL_DIR"/rtcw ]] && rm -rf "$INSTALL_DIR"/rtcw ~/.wolf ~/.local/share/applications/rtcw.desktop
}

uninstall() {
    read -p "Do you want to uninstall Return to Castle Wolfenstein (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/rtcw ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -e $INSTALL_DIR/rtcw ]]; then
    echo -e "Return to Castle Wolfenstein already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/rtcw.desktop ]]; then
        cat <<EOF >~/.local/share/applications/rtcw.desktop
[Desktop Entry]
Name=Return to Castle Wolfenstein
Exec=${INSTALL_DIR}/rtcw/iowolfsp.arm
Path=${INSTALL_DIR}/rtcw/
Icon=${INSTALL_DIR}/rtcw/icon.png
Type=Application
Comment=The dark reich's closing in. The time to act is now. Evil prevails when good men do nothing.
Categories=Game;
EOF
    fi
}

end_message() {
    echo -e "\nDone!. You can play typing $INSTALL_DIR/rtcw/iowolfsp.arm for single player or ./iowolfmp.arm for multiplayer or opening the Menu > Games > Return to Castle Wolfenstein.\n"
    runme
}

# get_demo_data_files() {
#     wget -O $HOME/wolf.run $PAK_FILE_SHARE
#     cd $HOME
#     tail -n +175 wolf.run | tar -xz demomain/pak0.pk3
#     rm -r wolf.run demomain
# }

install() {
    local DATA_URL
    clear
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    generate_icon
    echo
    read -p "Do you have an online copy of Return to Castle Wolfenstein (y/N)?: " response
    if [[ $response =~ [Yy] ]]; then
        DATA_URL="$(extract_url_from_file 18)"
        
        if ! message_magic_air_copy "$DATA_URL"; then
            echo -e "\nOverwrite /Main directory with new files into $INSTALL_DIR/rtcw.\n\nInstalling binaries..."
        else
            download_and_extract "$DATA_URL" "$INSTALL_DIR"/rtcw
        fi
    else
        echo -e "\nOverwrite /Main directory with new files into $INSTALL_DIR/rtcw.\n\nInstalling binaries..."
    fi
    end_message
}

install_script_message
echo "
Return to Castle Wolfenstein for Raspberry Pi
=============================================

 · Install path: $INSTALL_DIR/rtcw
 · PDF with default keys: $INSTALL_DIR/rtcw/quick_reference_card.pdf.
 · Total disk space required: 19 MB (binaries) + ~750 MB (full data).
"
read -p "Press [ENTER] to continue..."

install
