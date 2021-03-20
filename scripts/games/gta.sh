#!/bin/bash
#
# Description : GTA thks to foxhound311
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (20/Mar/21)
# Compatible  : Raspberry Pi 4 (tested)
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libopenal1 libsndfile1 libmpg123-0)
# readonly PACKAGES=(libopenal1 libglew2.1 libglfw3 libsndfile1 libmpg123-0)
readonly GTA3_BINARY_URL="https://misapuntesde.com/rpi_share/gta3-bin-rpi.tar.gz"
readonly LIBGLFW3_URL="https://misapuntesde.com/rpi_share/libglfw3_3.3.2-1_armhf.deb"
readonly VAR_DATA_GTA3_NAME="GTA_3"
readonly INPUT=/tmp/temp.$$

# GTA III

runme_gta3() {
    if [[ ! -f $INSTALL_DIR/GTAIII/re3 ]]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR/GTAIII" && ./re3
    exit_message
}

uninstall_gta3() {
    if [[ ! -d $INSTALL_DIR/GTAIII ]]; then
        return 0
    fi
    read -p "Do you want to uninstall Grand Theft Auto III (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR"/GTAIII ~/.local/share/applications/GTAIII.desktop
        if [[ -e "$INSTALL_DIR"/GTAIII ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

generate_icon_gta3() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/GTAIII.desktop ]]; then
        cat <<EOF >~/.local/share/applications/GTAIII.desktop
[Desktop Entry]
Name=Grand Theft Auto III
Version=1.0
Type=Application
Comment=Grand Theft Auto III is a 2001 open-world video game that is the third main entry of the Grand Theft Auto franchise.
Exec=${INSTALL_DIR}/GTAIII/re3
Icon=${INSTALL_DIR}/GTAIII/Icons/gta3.ico
Path=${INSTALL_DIR}/GTAIII/
Terminal=false
Categories=Game;
EOF
    fi
}

download_data_files_gta3() {
    DATA_URL=$(extract_path_from_file "$VAR_DATA_GTA3_NAME")
    if [[ $DATA_URL == "" ]]; then
        false
        return
    fi
    message_magic_air_copy "$DATA_URL"
    download_and_extract "$DATA_URL" "$INSTALL_DIR/GTAIII"
    true
    return
}

install_additional_packages() {
    download_and_install "$LIBGLFW3_URL"
}

install_gta3() {
    uninstall_gta3
    install_script_message
    echo "
Grand Theftt Auto III for Raspberry Pi
======================================

 · All credits goes to foxhound311.
 · This is only the engine. You must provide/copy ALL the folders of your copy of the game inside the install path.
 · Install path: $INSTALL_DIR/GTAIII
"
    read -p "Press [ENTER] to continue..."
    install_packages_if_missing "${PACKAGES[@]}"
    install_additional_packages
    echo -e "\nInstalling binary files..."
    download_and_extract "$GTA3_BINARY_URL" "$INSTALL_DIR"
    generate_icon_gta3
    if exists_magic_file && download_data_files_gta3; then
        echo -e "\n\nDone!. You can play typing $INSTALL_DIR/GTAIII/re3 or opening the Menu > Games > Grand Theft Auto III.\n"
        runme_gta3
    else
        echo -e "\nCopy all the data files from your copy inside $INSTALL_DIR/GTAIII.\n\nYou can play typing $INSTALL_DIR/GTAIII/re3 or opening the Menu > Games > Grand Theft Auto III."
        exit_message
    fi
}

menu() {
    while true; do
        dialog --clear \
            --title "[ Grand Theftt Auto ]" \
            --menu "Select from the list:" 11 70 3 \
            GTA3 "Grand Theftt Auto III" \
            GTAVC "Not yet available!" \
            Exit "Exit" 2>"${INPUT}"

        menuitem=$(<"${INPUT}")

        case $menuitem in
        GTA3) clear && install_gta3 ;;
        GTAVC) clear && exit ;;
        Exit) exit ;;
        esac
    done
}

install_gta3
