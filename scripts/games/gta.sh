#!/bin/bash
#
# Description : GTA thks to foxhound311
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.2 (10/Sep/21)
# Compatible  : Raspberry Pi 4 (tested)
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libopenal1 libsndfile1 libmpg123-0)
readonly GTA3_BINARY_URL="https://misapuntesde.com/rpi_share/gta3-bin-rpi.tar.gz"
readonly GTAVC_BINARY_URL="https://misapuntesde.com/rpi_share/gtavc-bin-rpi.tar.gz"
readonly LIBGLFW3_URL="https://misapuntesde.com/rpi_share/libglfw3_3.3.2-1_armhf.deb"
readonly VAR_DATA_GTA3_NAME="GTA_3"
readonly VAR_DATA_GTAVC_NAME="GTA_VC"
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
Exec=${INSTALL_DIR}/GTAIII/re3.sh
Icon=${INSTALL_DIR}/GTAIII/gta3.ico
Path=${INSTALL_DIR}/GTAIII/
Terminal=true
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
    if [[ ! -e /usr/lib/arm-linux-gnueabihf/libglfw.so.3 ]]; then
        download_and_install "$LIBGLFW3_URL"
    fi
}

install_gta3() {
    uninstall_gta3
    install_script_message
    echo "
Grand Theft Auto III for Raspberry Pi
=====================================

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
        echo -e "\n\nDone!. You can play typing $INSTALL_DIR/GTAIII/re3.sh or opening the Menu > Games > Grand Theft Auto III.\n"
        runme_gta3
    else
        echo -e "\nCopy all the data files from your copy inside $INSTALL_DIR/GTAIII.\n\nYou can play typing $INSTALL_DIR/GTAIII/re3.sh or opening the Menu > Games > Grand Theft Auto III."
        exit_message
    fi
}

# GTA VC

runme_gtavc() {
    if [[ ! -f $INSTALL_DIR/GTAVC/reVC ]]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR/GTAVC" && ./reVC
    exit_message
}

uninstall_gtavc() {
    if [[ ! -d $INSTALL_DIR/GTAVC ]]; then
        return 0
    fi
    read -p "Do you want to uninstall Grand Theft Auto Vice City (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR"/GTAVC ~/.local/share/applications/GTAVC.desktop
        if [[ -e "$INSTALL_DIR"/GTAVC ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

generate_icon_gtavc() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/GTAVC.desktop ]]; then
        cat <<EOF >~/.local/share/applications/GTAVC.desktop
[Desktop Entry]
Name=Grand Theft Auto Vice City
Version=1.0
Type=Application
Comment=Grand Theft Auto VC is a 2002 open-world video game that takes place in the middle of the 80's in a fictional place called Vice City.
Exec=${INSTALL_DIR}/GTAVC/reVC.sh
Icon=${INSTALL_DIR}/GTAVC/gtavc.ico
Path=${INSTALL_DIR}/GTAVC/
Terminal=true
Categories=Game;
EOF
    fi
}

download_data_files_gtavc() {
    DATA_URL=$(extract_path_from_file "$VAR_DATA_GTAVC_NAME")
    if [[ $DATA_URL == "" ]]; then
        false
        return
    fi
    message_magic_air_copy "$DATA_URL"
    download_and_extract "$DATA_URL" "$INSTALL_DIR/GTAVC"
    true
    return
}

install_gtavc() {
    uninstall_gtavc
    install_script_message
    echo "
Grand Theft Auto Vice City for Raspberry Pi
===========================================

 · All credits goes to foxhound311.
 · This is only the engine. You must provide/copy ALL the folders of your copy of the game inside the install path.
 · Install path: $INSTALL_DIR/GTAVC
"
    read -p "Press [ENTER] to continue..."
    install_packages_if_missing "${PACKAGES[@]}"
    install_additional_packages
    echo -e "\nInstalling binary files..."
    download_and_extract "$GTAVC_BINARY_URL" "$INSTALL_DIR"
    generate_icon_gtavc
    if exists_magic_file && download_data_files_gtavc; then
        echo -e "\n\nDone!. You can play typing $INSTALL_DIR/GTAVC/reVC.sh or opening the Menu > Games > Grand Theft Auto Vice City.\n"
        runme_gtavc
    else
        echo -e "\nCopy all the data files from your copy inside $INSTALL_DIR/GTAVC.\n\nYou can play typing $INSTALL_DIR/GTAVC/reVC.sh or opening the Menu > Games > Grand Theft Auto Vice City."
        exit_message
    fi
}

menu() {
    while true; do
        dialog --clear \
            --title "[ Grand Theft Auto ]" \
            --menu "Select from the list:" 11 70 3 \
            GTA3 "Grand Theft Auto III" \
            GTAVC "Grand Theft Auto Vice City" \
            Exit "Exit" 2>"${INPUT}"

        menuitem=$(<"${INPUT}")

        case $menuitem in
        GTA3) clear && install_gta3 ;;
        GTAVC) clear && install_gtavc ;;
        Exit) exit ;;
        esac
    done
}

menu
