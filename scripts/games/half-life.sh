#!/bin/bash
#
# Description : Half Life thks to Salva (Pi Labs)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.3 (29/Sep/20)
# Compatible  : Raspberry Pi (tested)
# Repository  : https://github.com/ValveSoftware/halflife
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES_DEV=(libsdl2-dev)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/half-life-0.20-bin-rpi.tar.gz"
readonly HQ_TEXTURE_PACK_URL="https://gamebanana.com/dl/265907"
readonly SOURCE_CODE_URL="https://github.com/FWGS/xash3d"
readonly ES_TRANSLATION_URL="https://archive.org/download/rpi_share/hl-sp-patch.tar.gz"

runme() {
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/half-life && ./half-life.sh
    echo
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/half-life  ~/.local/share/applications/half-life.desktop
}

uninstall() {
    read -p "Do you want to uninstall Half Life (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/half-life ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/half-life ]]; then
    echo -e "Half Life already installed.\n"
    uninstall
    exit 0
fi

generate_icon() {
    if [[ ! -e ~/.local/share/applications/half-life.desktop ]]; then
cat << EOF > ~/.local/share/applications/half-life.desktop
[Desktop Entry]
Name=Half Life
Exec=${INSTALL_DIR}/half-life/half-life.sh
Icon=${INSTALL_DIR}/half-life/hl.ico
Path=${INSTALL_DIR}/half-life/
Type=Application
Comment=Players assume the role of Gordon Freeman, a scientist who must find his way out of the Black Mesa Research Facility after it is invaded by aliens
Categories=Game;ActionGame;
EOF
    fi
}

post_install() {
    if [[ $(get_keyboard_layout) == "es" ]]; then
        echo
        echo "Detected Latin/Spanish user. Applying translation..."
        download_and_extract "$ES_TRANSLATION_URL" "$INSTALL_DIR/half-life"
    fi
}

install() {
    local DATA_URL
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    echo
    read -p "Do you have an original copy of Half Life (Y/n)?: " response
    if [[ $response =~ [Nn] ]]; then
        generate_icon
        echo -e "\nDone!. Now copy the /valve directory inside $INSTALL_DIR/half-life"
        exit_message
    fi

    DATA_URL=$(extract_url_from_file 14)
    installPackagesIfMissing p7zip-full
    message_magic_air_copy
    download_and_extract "$DATA_URL" "$INSTALL_DIR"/half-life
    generate_icon
    post_install
    echo -e "\nDone!."
    runme
}

echo "
Install Half Life on Raspberry Pi
=================================

 · If you want to disable fps cap, just open the console (tilde key in game) and type: cl_showfps 0
 · Languages in game: English, Spanish.
 · Based on engine at ${SOURCE_CODE_URL}
"
read -p "Press [ENTER] to go back to the menu..."

install
