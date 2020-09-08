#!/bin/bash
#
# Description : Quake ][, ]I[
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.1 (08/Sep/20)
# Compatible  : Raspberry Pi 4 (tested)
#
# Help 		  : Quake 1: https://github.com/welford/qurp
#               QuakeServer: https://www.recantha.co.uk/blog/?p=9962
#               Darkplaces Quake: https://github.com/petrockblog/RetroPie-Setup/tree/master/scriptmodules/ports
#               https://swissmacuser.ch/how-you-want-to-run-quake-iii-arena-in-2018-with-high-definition-graphics-120-fps-on-5k-resolution/
#               https://pimylifeup.com/raspberry-pi-quake-3/
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"

# Q1_DATA_URL="https://www.quakeforge.net/files/quake-shareware-1.06.zip"
readonly Q2_CONFIG_DIR="$HOME/.yq2"
readonly Q2_BINARY_URL="https://misapuntesde.com/rpi_share/yquake2_bin_arm.tar.gz"
readonly Q2_SOURCE_CODE_URL="https://github.com/yquake2/yquake2.git"
readonly Q2_OGG_URL="https://misapuntesde.com/rpi_share/q2_ogg.zip"
readonly Q2_HIGH_TEXTURE_PAK_URL="https://deponie.yamagi.org/quake2/texturepack/q2_textures.zip"
readonly Q2_HIGH_TEXTURE_MODELS_URL="https://deponie.yamagi.org/quake2/texturepack/models.zip"readonly 
Q2_DATA_URL="https://archive.org/download/rpi_share/baseq2.zip"
readonly Q3_PACKAGES_DEV=(libsdl2-dev libxxf86dga-dev libcurl4-openssl-dev)
readonly Q3_BINARY_URL="https://misapuntesde.com/rpi_share/quake3-1.32-rpi.tar.gz"
readonly Q3_SOURCE_CODE_URL="https://github.com/ec-/Quake3e.git"
Q3_DATA_URL=""
INPUT=/tmp/quake.$$

q2_runme() {
    if [ ! -f "$INSTALL_DIR"/yquake2/quake2 ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    "$INSTALL_DIR"/yquake2/quake2
    exit_message
}

q3_runme() {
    if [ ! -f "$INSTALL_DIR"/quake3/quake3e.sh ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
    fi

    if [ -d "$INSTALL_DIR"/quake3/baseq3 ]; then
        read -p "Press [ENTER] to run the game..."
        cd "$INSTALL_DIR"/quake3 && ./quake3e.sh
    fi

    exit_message
}

q2_check_if_installed() {
    if [[ ! -d "$INSTALL_DIR"/yquake2 ]]; then
        return 0
    fi

    echo
    read -p "Quake ][ already installed. Do you want to uninstall it (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR"/yquake2 ~/.local/share/applications/yquake2.desktop "$HOME"/.yq2
        if [[ -e "$INSTALL_DIR"/yquake2 ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi

        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi

    exit_message
}

q3_check_if_installed() {
    if [[ ! -d "$INSTALL_DIR"/quake3 ]]; then
        return 0
    fi

    echo
    read -p "Quake ]I[ already installed. Do you want to uninstall it (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR"/quake3 ~/.local/share/applications/quake3.desktop ~/.q3a
        if [[ -e "$INSTALL_DIR"/quake3 ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi

        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi

    exit_message
}

q2_generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/yquake2.desktop ]]; then
        cat <<EOF >~/.local/share/applications/yquake2.desktop
[Desktop Entry]
Name=Quake ][
Exec=${INSTALL_DIR}/yquake2/quake2
Icon=${INSTALL_DIR}/yquake2/quake2.svg
Path=${INSTALL_DIR}/yquake2/
Type=Application
Comment=Yamagi Quake II is an enhanced client for id Software's Quake II with focus on offline and coop gameplay.
Categories=Game;ActionGame;
EOF
    fi
}

q3_generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/quake3.desktop ]]; then
        cat <<EOF >~/.local/share/applications/quake3.desktop
[Desktop Entry]
Name=Quake ]I[
Exec=${INSTALL_DIR}/quake3/quake3e.sh
Icon=${INSTALL_DIR}/quake3/icon.png
Path=${INSTALL_DIR}/quake3/
Type=Application
Comment=Quake III Arena is a 1999 multiplayer-focused first-person shooter developed by id Software. It is the third game in the Quake series; it differs from previous games by excluding a story-based single-player mode
Categories=Game;ActionGame;
EOF
    fi
}

q2_install_binary() {
    echo -e "\nInstalling binary files..."
    download_and_extract "$Q2_BINARY_URL" "$INSTALL_DIR"
    mv -f "$INSTALL_DIR"/yquake2/.yq2 ~/
}

q2_compile() {
    echo -e "\nInstalling Dependencies..."
    sudo apt install -y libsdl2-dev libopenal-dev
    mkdir -p "$HOME"/sc
    git clone "$Q2_SOURCE_CODE_URL" yquake2 && cd "$_"
    # TODO Add on Makefile -march=armv7
    make -j"$(getconf _NPROCESSORS_ONLN)"
    echo -e "\nDone!. "
}

q2_soundtrack_download() {
    echo -e "\nInstalling sound tracks..."
    download_and_extract "$Q2_OGG_URL" "$Q2_CONFIG_DIR"/baseq2
}

q2_high_textures_download() {
    echo -e "\nInstalling high texture pack..."
    download_and_extract "$Q2_HIGH_TEXTURE_PAK_URL" "$Q2_CONFIG_DIR"/baseq2
    echo "Installing high texture models..."
    download_and_extract "$Q2_HIGH_TEXTURE_MODELS_URL" "$Q2_CONFIG_DIR"/baseq2
}

q2_install() {
    q2_check_if_installed
    echo "
Quake ][ for Raspberry Pi
=========================

 · Start at 720p (You can change it) with OpenGL 1.4.
 · High textures.
 · OGG soundtrack.
 · Install path: $INSTALL_DIR/yquake2
"
    read -p "Press [Enter] to install the game..."

    echo -e "\n\nInstalling Quake ][, please wait...\n"
    mkdir -p "$INSTALL_DIR"
    q2_install_binary
    q2_soundtrack_download
    q2_high_textures_download
    q2_generate_icon
    echo
    read -p "Do you have an original copy of Quake ][ (If not, a shareware version will be installed) (y/N)?: " response
    if [[ $response =~ [Yy] ]]; then
        Q2_DATA_URL=$(extract_url_from_file 5)
        message_magic_air_copy
    fi

    download_and_extract "$Q2_DATA_URL" "$Q2_CONFIG_DIR"
    echo -e "\n\nDone!. You can play typing $INSTALL_DIR/yquake2/quake2 or opening the Menu > Games > Quake ][.\n"
    q2_runme
}

q3_install_data() {
    echo
    read -p "Do you have an original copy of Quake ]I[ (Y/n)?: " response
    if [[ $response =~ [Nn] ]]; then
        echo -e "\n\nCopy the data files (baseq3 directory) into $INSTALL_DIR/quake3.\n"
        return 0
    fi

    Q3_DATA_URL=$(extract_url_from_file 13)
    message_magic_air_copy
    download_and_extract "$Q3_DATA_URL" "$INSTALL_DIR"/quake3
}

q3_install_binary() {
    local CFG_DIRECTORY_PATH
    local FILE_CFG_PATH
    CFG_DIRECTORY_PATH="$HOME/.q3a/baseq3"
    FILE_CFG_PATH="$INSTALL_DIR"/quake3/q3config.cfg

    echo -e "\n\nInstalling Quake ]I[, please wait...\n"
    download_and_extract "$Q3_BINARY_URL" "$INSTALL_DIR"
    if [ -f "$FILE_CFG_PATH" ]; then
        mkdir -p "$CFG_DIRECTORY_PATH" && cp "$FILE_CFG_PATH" "$CFG_DIRECTORY_PATH"
    fi
}

q3_install() {
    q3_check_if_installed
    echo "
Quake ]I[ for Raspberry Pi
==========================

 · Based on Quake3e engine.
 · OpenGL and Vulkan supported.
 · Some tweaks settings to get features like HDR, dynamic lights,...
 · High quality textures thanks to https://www.moddb.com/mods/high-quality-quake/downloads/hqq-high-quality-quake-v37-test
 · Config file at ~/.q3a/baseq3/q3config.cfg
 · Install path: $INSTALL_DIR/quake3
 · NOTE: It uses your OS resolution, even if you change it on config file.
"
    read -p "Press [Enter] to install the game..."
    q3_install_binary
    q3_generate_icon
    q3_install_data
    echo -e "\nDone!. You can play typing $INSTALL_DIR/quake3/quake3e or opening the Menu > Games > Quake ]I[.\n"
    q3_runme
}

q3_compile() {
    installPackagesIfMissing "${Q3_PACKAGES_DEV[@]}"
    mkdir -p ~/sc && cd "$_"
    echo -e "\nCloning and compiling Quake ]I[...\n"
    [[ ! -d ~/sc/Quake3e ]] && git clone "$Q3_SOURCE_CODE_URL"
    cd ~/sc/Quake3e/
    make -j"$(nproc)" OPTOPT="-march=armv8-a+crc -mtune=cortex-a53" BUILD_SERVER=0 USE_RENDERER_DLOPEN=0 USE_VULKAN=1
    echo -e "\nDone!. Binary files at build/release-linux-arm"
    exit_message
}

menu() {
    while true; do
        dialog --clear \
            --title "[ Quake for Raspberry Pi ]" \
            --menu "Choose language:" 11 100 3 \
            Quake2 "It is not a direct sequel to Quake. The player is given mission-based objectives" \
            Quake3 "1999 multiplayer-focused fps that no have a story-based single-player mode" \
            Exit "Back to main menu" 2>"${INPUT}"

        menuitem=$(<"${INPUT}")

        case $menuitem in
        Quake2) clear && q2_install && return 0 ;;
        Quake3) clear && q3_install && return 0 ;;
        Exit) exit 0 ;;
        esac
    done
}

menu