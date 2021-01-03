#!/bin/bash
#
# Description : Blood
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.6 (03/Jan/21)
# Compatible  : Raspberry Pi 4 (tested)
#
# Help		  : https://www.techradar.com/how-to/how-to-run-wolfenstein-3d-doom-and-duke-nukem-on-your-raspberry-pi
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly BINARY_URL="https://misapuntesde.com/rpi_share/blood_r12112.tar.gz"
readonly PACKAGES_DEV=(build-essential nasm libgl1-mesa-dev libglu1-mesa-dev libsdl1.2-dev libsdl-mixer1.2-dev libsdl2-dev libsdl2-mixer-dev flac libflac-dev libvorbis-dev libvpx-dev libgtk2.0-dev freepats)
readonly SOURCE_CODE_URL="https://github.com/nukeykt/NBlood.git"
readonly VAR_DATA_NAME="BLOOD_FULL"
INPUT=/tmp/blood.$$

runme() {
    if [ ! -f "$INSTALL_DIR"/blood/nblood ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/blood && ./nblood
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/blood ~/.local/share/applications/blood.desktop ~/.config/nblood
}

uninstall() {
    read -p "Do you want to uninstall Blood (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/blood ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/blood ]]; then
    echo -e "Blood already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/blood.desktop ]]; then
        cat <<EOF >~/.local/share/applications/blood.desktop
[Desktop Entry]
Name=Blood
Exec=${PWD}/blood/nblood
Icon=${PWD}/blood/blood.png
Path=${PWD}/blood/
Type=Application
Comment=Blood is a fps game.The game follows the story of Caleb, an undead early 20th century gunfighter seeking revenge against the dark god Tchernobog.
Categories=Game;ActionGame;
EOF
    fi
}

download_data_files() {
    cd "$INSTALL_DIR/blood" || exit 1
    download_and_extract "$DATA_URL" "$INSTALL_DIR"
}

end_message() {
    echo -e "\n\nDone!. You can play typing $INSTALL_DIR/blood/blood or opening the Menu > Games > Blood.\n"
    runme
}

# Check https://github.com/nukeykt/NBlood/issues/332
fix_path() {
    echo -e "Fixing code...\n" && sleep 3
    sed -i -e 's/  glrendmode = (settings.polymer) ? REND_POLYMER : REND_POLYMOST;/  int glrendmode = (settings.polymer) ? REND_POLYMER : REND_POLYMOST;/g' source/duke3d/src/startgtk.game.cpp
    sed -i 's/    LIBS += -lrt/    LIBS += -lrt -latomic/g' ./Common.mak
    sed -i 's/    return r;/    return 0;/g' source/build/include/zpl.h
}

compile() {
    echo -e "\nInstalling dependencies (if proceed)...\n"
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" || exit 1
    echo
    git clone "$SOURCE_CODE_URL" blood && cd "$_" || exit 1
    fix_path
    echo -e "\n\nCompiling... Estimated time on RPi 4: <5 min.\n"
    make -j"$(nproc)" WITHOUT_GTK=1 POLYMER=1 USE_LIBVPX=0 HAVE_FLAC=0 OPTLEVEL=3 LTO=0 RENDERTYPESDL=1 HAVE_JWZGLES=1 USE_OPENGL=1 OPTOPT="-march=armv8-a+crc -mtune=cortex-a53"
    echo -e "\nDone. Copy the data files inside $INSTALL_DIR/blood. You can play typing $INSTALL_DIR/blood/nblood"
    exit_message
}

download_binaries() {
    echo -e "\nInstalling binary files..."
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
}

install() {
    install_script_message
    echo -e "\n\nInstalling, please wait..."
    mkdir -p "$INSTALL_DIR" && cd "$_" || exit 1
    download_binaries
    generate_icon
    echo
    read -p "Do you have data files set on the file res/magic-air-copy-pikiss.txt for Blood (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME")
            if ! message_magic_air_copy "$DATA_URL"; then
        echo -e "\nNow copy data directory into $INSTALL_DIR/blood."
        return 0
    fi 
        download_data_files
        end_message
    fi

    echo -e "\nDone. Copy the data files inside $INSTALL_DIR/blood."
    echo -e "\nYou can play typing $INSTALL_DIR/blood/nblood or opening the Menu > Games > Blood."
    exit_message
}

menu() {
    while true; do
        dialog --clear \
            --title "[ Blood ]" \
            --menu "Select from the list:" 11 68 3 \
            INSTALL "Binary compiled 03/Jan/21 (Recommended)" \
            COMPILE "Latest from source code. Estimated time: 5 minutes." \
            Exit "Exit" 2>"${INPUT}"

        menuitem=$(<"${INPUT}")

        case $menuitem in
        INSTALL) clear && install ;;
        COMPILE) clear && compile ;;
        Exit) exit ;;
        esac
    done
}

menu
