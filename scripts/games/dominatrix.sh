#!/bin/bash
#
# Description: Dominatrix for Raspberry Pi (Sin Gold)
# Author     : Jose Cerrejon Gonzalez (ulysess@gmail.com)
# Version    : 1.0.0 (14/08/2025)
# Tested     : Raspberry Pi 5
#
# shellcheck source=../helper.sh
# shellcheck disable=SC1094
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh..." && exit 1; }
clear

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libsdl2-dev libsdl2-mixer-dev)
readonly GITHUB_REPO_URL="https://github.com/rohit-n/dominatrix"
readonly ICON_URL="https://images.gog-statics.com/63bde3b538e826dc4fe419f2c63b3d121ad10c29c01cfa05cd1178c84ee25504.png"
readonly BINARY_URL="https://github.com/rohit-n/dominatrix/releases/download/v1.2/dominatrix-linux-v1.2-aarch64.tar.gz"
readonly VAR_DATA_NAME="SIN"

runme() {
    if [ ! -d "$INSTALL_DIR/dominatrix" ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR/dominatrix" && ./wages_of_sin.sh
    exit_message
}

uninstall() {
    if ask_yes_no "Do you want to uninstall Dominatrix (Sin Gold)?"; then
        rm -rf "$INSTALL_DIR/dominatrix" "$HOME/.local/share/applications/dominatrix.desktop"
        if [[ -e "$INSTALL_DIR/dominatrix" ]]; then
            echo -e "I hate when this happens. I could not remove the directory, Try to remove it manually.\n"
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
}

if [[ -d $INSTALL_DIR/dominatrix ]]; then
    echo -e "Dominatrix (Sin Gold) already installed.\n"
    uninstall
    exit 0
fi

generate_icon() {
    echo -e "Downloading icon...\n"
    download_file "$ICON_URL" "$INSTALL_DIR/dominatrix"
    if [[ ! -e "$HOME/.local/share/applications/dominatrix.desktop" ]]; then
        cat <<EOF >"$HOME/.local/share/applications/dominatrix.desktop"
[Desktop Entry]
Name=Dominatrix (Sin Gold)
Exec=${INSTALL_DIR}/dominatrix/wages_of_sin.sh
Icon=${INSTALL_DIR}/dominatrix/63bde3b538e826dc4fe419f2c63b3d121ad10c29c01cfa05cd1178c84ee25504.png
Type=Application
Comment=Dominatrix is a free and open-source game inspired by the classic game Sin Gold Edition.
Categories=Game;
Path=${INSTALL_DIR}/dominatrix/
EOF
    fi
}

magic_air_copy() {
    if exists_magic_file; then
        DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME")
        message_magic_air_copy "$VAR_DATA_NAME"
        if [[ -n "$DATA_URL" ]]; then
            download_and_extract "$DATA_URL" "$INSTALL_DIR/dominatrix"
        else
            echo -e "\nNo se encontró la URL de datos para $VAR_DATA_NAME.\n"
        fi
    fi
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    # Comprobar si el directorio extraído existe antes de mover
    if [[ -d "$INSTALL_DIR/dominatrix-linux-v1.2-aarch64" ]]; then
        mv "$INSTALL_DIR/dominatrix-linux-v1.2-aarch64" "$INSTALL_DIR/dominatrix"
    fi
    generate_icon
    magic_air_copy
    echo -e "\nDone!. To play, go to Menu > Games > Dominatrix (Sin Gold) or type $INSTALL_DIR/dominatrix."
    runme
}

install_script_message
echo "
Dominatrix for Raspberry Pi (Sin Gold)
======================================

 · Thanks to Rohit Nirmal for providing the aarch64 build.
 · NOTE: The original game assets are required. You can buy the game on GOG if you don't have them.
"
if ! ask_yes_no "Do you want to install it?"; then
    exit_message
fi

install
