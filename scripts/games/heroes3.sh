#!/bin/bash
#
# Description : VCMI. Open-source engine for Heroes of Might and Magic III
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.1 (25/Oct/21)
# Compatible  : Raspberry Pi 4
# Repository  : https://github.com/vcmi/vcmi
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES_MM3=(libboost-date-time1.67.0 libboost-locale1.67.0 p7zip-full)
readonly PACKAGES_MM3_DEV=(libboost-date-time1.67.0-dev libboost-locale1.67.0-dev)
readonly BINARY_MM3_URL="https://misapuntesde.com/rpi_share/heroes3-0.99dev-rpi.7z"
readonly DEMO_MM3_URL="https://e.pcloud.link/publink/show?code=XZAAk0Z8P6jmN12mTQic0hDRPqhhu6yQg0y"
readonly SOURCE_CODE_MM3_URL="https://github.com/vcmi/vcmi"
readonly VAR_DATA_MM3_NAME="HEROES_3"
INPUT=/tmp/temp.$$

runme_mm3() {
    if [[ ! -f $INSTALL_DIR/heroes3/vcmilauncher ]]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/heroes3 && ./vcmilauncher
    exit_message
}

uninstall_mm3() {
    read -p "Do you want to uninstall Heroes of Might and Magic III (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR"/heroes3 ~/.local/share/applications/heroes3.desktop ~/.vcmi
        if [[ -e "$INSTALL_DIR"/heroes3 ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/heroes3 ]]; then
    echo -e "Heroes of Might and Magic III already installed.\n"
    uninstall_mm3
fi

generate_icon_mm3() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/heroes3.desktop ]]; then
        cat <<EOF >~/.local/share/applications/heroes3.desktop
[Desktop Entry]
Name=Heroes of Might and Magic III
Version=1.0
Type=Application
Comment=Open-source engine for Heroes of Might and Magic III
Exec=${INSTALL_DIR}/heroes3/vcmilauncher
Icon=${INSTALL_DIR}/heroes3/launcher/icons/menu-game.png
Path=${INSTALL_DIR}/heroes3/
Terminal=false
Categories=Game;
EOF
    fi
}

end_message_mm3() {
    echo -e "\nDone!. You can play typing $INSTALL_DIR/heroes3/vcmilauncher or opening the Menu > Games > Heroes of Might and Magic III.\n"
}

get_demo_mm3() {
    echo -e "\nDownloading demo files..."
    download_and_extract "$DEMO_MM3_URL" "$INSTALL_DIR/heroes3"
}

download_data_files() {
    local DATA_URL
    DATA_URL=$(extract_path_from_file "$VAR_DATA_MM3_NAME")
    if [[ $DATA_URL == "" ]]; then
        false
        return
    fi
    message_magic_air_copy "$DATA_URL"
    download_and_extract "$DATA_URL" "$INSTALL_DIR/heroes3"
    true
    return
}

install_mm3() {
    install_script_message
    echo "
Heroes of Might and Magic III engine (vcmi) for Raspberry Pi
============================================================

 · Thanks phoenixbyrd for the binary files of the engine.
 · Free implementation of Heroes of Might and Magic III engine.
 · F4: Full screen.
 · You need to supply for full game experience the directories /Data, /Maps & /Mp3 into $INSTALL_DIR/heroes3
 · If you don't provide game data files inside res/magic-air-copy-pikiss.txt, demo will be installed.
"
    read -p "Press [Enter] to continue..."

    install_packages_if_missing "${PACKAGES_MM3[@]}"
    download_and_extract "$BINARY_MM3_URL" "$INSTALL_DIR"
    generate_icon_mm3
    if exists_magic_file && download_data_files; then
        download_data_files
        end_message_mm3
        runme_mm3
    else
        get_demo_mm3
        end_message_mm3
        runme_mm3
    fi

}

install_mm3
