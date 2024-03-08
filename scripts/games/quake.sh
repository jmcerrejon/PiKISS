#!/bin/bash
#
# Description : Quake I, ][, ]I[
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.5.1 (8/Mar/24)
# Tested      : Raspberry Pi 5
#
# Help 		  : Quake 1: | https://godmodeuser.com/p/8#40
#               QuakeServer: https://www.recantha.co.uk/blog/?p=9962
#               Darkplaces Quake: https://github.com/petrockblog/RetroPie-Setup/tree/master/scriptmodules/ports
#               https://swissmacuser.ch/how-you-want-to-run-quake-iii-arena-in-2018-with-high-definition-graphics-120-fps-on-5k-resolution/
#               https://pimylifeup.com/raspberry-pi-quake-3/
#
# shellcheck source=../helper.sh
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly Q1_VERSION="0.96.1"
readonly Q1_PACKAGES=(libogg0 libvorbis0a)
readonly Q1_PACKAGES_DEV=(libsdl2-dev libvorbis-dev libmad0-dev)
readonly Q1_VK_PACKAGES_DEV=(meson glslang-tools spirv-tools libsdl2-dev libvulkan-dev libvorbis-dev libmad0-dev libx11-xcb-dev)
readonly Q1_BINARY_URL="https://misapuntesde.com/rpi_share/quakespasm-${Q1_VERSION}.tar.gz"
readonly Q1_SOUNDTRACK_URL="https://www.quaddicted.com/files/music/quake_campaign_soundtrack.zip"
readonly Q1_SOURCE_CODE_1_URL="https://sourceforge.net/projects/quakespasm/files/Source/quakespasm-${Q1_VERSION}.tar.gz/download"
readonly Q1_SOURCE_CODE_2_VK_URL="https://github.com/vsonnier/vkQuake-vso"
readonly Q2_CONFIG_DIR="$HOME/.yq2"
readonly Q2_BINARY_URL="https://misapuntesde.com/rpi_share/yquake2_bin_arm.tar.gz"
readonly Q2_BINARY_AARCH64_URL="https://misapuntesde.com/rpi_share/yquake2-rpi-aarch64.tar.gz"
readonly Q2_SOURCE_CODE_URL="https://github.com/yquake2/yquake2.git"
readonly Q2_OGG_URL="https://misapuntesde.com/rpi_share/q2_ogg.zip"
readonly Q2_HIGH_TEXTURE_PAK_URL="https://deponie.yamagi.org/quake2/texturepack/textures.zip"
readonly Q2_HIGH_TEXTURE_MODELS_URL="https://deponie.yamagi.org/quake2/texturepack/models.zip"
readonly Q3_PACKAGES_DEV=(libsdl2-dev libxxf86dga-dev libcurl4-openssl-dev)
readonly Q3_BINARY_URL="https://misapuntesde.com/rpi_share/quake3-rpi.tar.gz"
readonly Q3_SOURCE_CODE_URL="https://github.com/ec-/Quake3e.git"
readonly VAR_DATA_NAME_1="QUAKE_1"
readonly VAR_DATA_NAME_2="QUAKE_2"
readonly VAR_DATA_NAME_3="QUAKE_3"
Q1_DATA_URL="https://misapuntesde.com/rpi_share/quake1-shareware.tar.gz"
Q2_DATA_URL="https://misapuntesde.com/rpi_share/baseq2_share.tar.gz"
Q3_DATA_URL=""
INPUT=/tmp/quake.$$

# Quake 1

q1_runme() {
    if [ ! -f "$INSTALL_DIR"/quake/run.sh ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/quake && ./run.sh
    exit_message
}

q1_check_if_installed() {
    if [[ ! -d "$INSTALL_DIR"/quake ]]; then
        return 0
    fi

    echo
    read -p "Quake already installed. Do you want to uninstall it (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR"/quake ~/.local/share/applications/quake.desktop
        if [[ -e "$INSTALL_DIR"/quake ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi

        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi

    exit_message
}

q1_generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/quake.desktop ]]; then
        cat <<EOF >~/.local/share/applications/quake.desktop
[Desktop Entry]
Name=Quake
Exec=${INSTALL_DIR}/quake/run.sh
Icon=${INSTALL_DIR}/quake/logo.png
Path=${INSTALL_DIR}/quake/
Type=Application
Comment=The game focused on the player known as Ranger, who travels across alternate dimensions to stop an enemy code-named 'Quake'
Categories=Game;ActionGame;
EOF
    fi
}

q1_install_binary() {
    echo -e "\nInstalling binary files..."
    download_and_extract "$Q1_BINARY_URL" "$INSTALL_DIR"
}

q1_opengl_compile() {
    echo -e "\nInstalling Dependencies..."
    install_packages_if_missing "${Q1_PACKAGES_DEV[@]}"
    mkdir -p "$HOME"/sc && cd "$_" || exit 1
    wget -O quakespasm.tar.gz "$Q1_SOURCE_CODE_1_URL" && tar -xzf quakespasm.tar.gz && rm quakespasm.tar.gz
    cd "$HOME/sc/quakespasm-${Q1_VERSION}/Quake" || exit 1
    make_with_all_cores USE_SDL2=1
    echo -e "\nDone!. Check at $HOME/sc/quakespasm-0.96.1/Quake/quakespasm"
    exit_message
}

q1_vulkan_compile() {
    # FIX: It fails due Mesa Driver issues. Check out: https://github.com/Novum/vkQuake/issues/616
    echo -e "\nInstalling Dependencies..."
    install_packages_if_missing "${Q1_VK_PACKAGES_DEV[@]}"
    mkdir -p "$HOME"/sc && cd "$_" || exit 1
    git clone "$Q1_SOURCE_CODE_2_VK_URL"
    cd "$HOME"/sc/vkQuake-vso/Quake || exit 1
    time meson build && ninja -C build
    echo -e "\nDone!. Check at $HOME/sc/vkQuake-vso/build/vkquake"
    exit_message
}

q1_soundtrack_download() {
    if [[ ! -d $INSTALL_DIR/quake/id1 ]]; then
        mkdir -p "$INSTALL_DIR/quake/id1"
    fi
    echo -e "\nInstalling sound tracks..."
    download_and_extract "$Q1_SOUNDTRACK_URL" /tmp
    mv /tmp/quake_campaign_soundtrack/id1/music "$INSTALL_DIR"/quake/id1
    mv /tmp/quake_campaign_soundtrack/id1/tracklist.cfg "$INSTALL_DIR"/quake/id1
}

q1_magic_air_copy() {
    if exists_magic_file; then
        Q1_DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME_1")
        message_magic_air_copy "$VAR_DATA_NAME_1"
    fi
    download_and_extract "$Q1_DATA_URL" "$HOME"/games/quake
}

q1_install() {
    q1_check_if_installed
    install_script_message
    echo "
Quake for Raspberry Pi
======================

 · Quakespam version ${Q1_VERSION}.
 · If you don't provide game data file inside res/magic-air-copy-pikiss.txt, shareware version will be installed.
 · Make sure all data files are lowercase, e.g. pak0.pak, not PAK0.PAK. Some distributions of the game have upper case file names.
 · SDL2 with graphic improvements through id1/autoexec.cfg. for more improvements visit https://www.celephais.net/fitzquake/#commands
"
    read -p "Press [Enter] to install the game..."
    echo -e "\n\nInstalling Quake, please wait...\n"
    install_packages_if_missing "${Q1_PACKAGES[@]}"
    mkdir -p "$INSTALL_DIR"
    q1_install_binary
    q1_soundtrack_download
    q1_generate_icon
    q1_magic_air_copy
    echo -e "\nDone!. You can play typing $INSTALL_DIR/quake/run.sh or opening the Menu > Games > Quake.\n"
    q1_runme
}

# Quake ][

q2_runme() {
    if [ ! -f "$INSTALL_DIR"/yquake2/quake2 ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    "$INSTALL_DIR"/yquake2/quake2
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

q2_install_binary() {
    local BINARY_URL
    BINARY_URL=$Q2_BINARY_URL

    if is_userspace_64_bits; then
        BINARY_URL=$Q2_BINARY_AARCH64_URL
    fi

    echo -e "\nInstalling binary files..."
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    cp -rf "$INSTALL_DIR"/yquake2/.yq2 ~/
}

q2_compile() {
    echo -e "\nInstalling Dependencies..."
    sudo apt install -y libsdl2-dev libopenal-dev libcurl4-gnutls-dev
    mkdir -p "$HOME"/sc && cd "$_" || exit 1
    git clone "$Q2_SOURCE_CODE_URL" yquake2 && cd "$_" || exit 1
    mkdir build && cd "$_" || exit 1
    cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
    make_with_all_cores
    echo -e "\nDone!. Check $HOME/sc/yquake2/build/release"
    exit_message
}

q2_soundtrack_download() {
    echo -e "\nInstalling sound tracks..."
    download_and_extract "$Q2_OGG_URL" "$Q2_CONFIG_DIR"/baseq2
}

q2_high_textures_download() {
    echo -e "\nInstalling high texture pack..."
    download_and_extract "$Q2_HIGH_TEXTURE_PAK_URL" "$Q2_CONFIG_DIR"/baseq2
    echo -e "\nInstalling high texture models..."
    download_and_extract "$Q2_HIGH_TEXTURE_MODELS_URL" "$Q2_CONFIG_DIR"/baseq2
}

q2_magic_air_copy() {
    if exists_magic_file; then
        Q2_DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME_2")
        message_magic_air_copy "$VAR_DATA_NAME_2"
    fi
    download_and_extract "$Q2_DATA_URL" "$Q2_CONFIG_DIR"
}

q2_install() {
    q2_check_if_installed
    install_script_message
    echo "
Quake ][ for Raspberry Pi
=========================

 · Start at 720p (You can change it) with OpenGL 1.4.
 · High textures.
 · OGG soundtrack.
 · Install path: $INSTALL_DIR/yquake2
 · If you don't provide game data file inside res/magic-air-copy-pikiss.txt, shareware version will be installed.
"
    read -p "Press [Enter] to install the game..."
    echo -e "\n\nInstalling Quake ][, please wait...\n"
    mkdir -p "$INSTALL_DIR"
    q2_install_binary
    q2_soundtrack_download
    q2_high_textures_download
    q2_generate_icon
    q2_magic_air_copy
    echo -e "\nDone!. You can play typing $INSTALL_DIR/yquake2/quake2 or opening the Menu > Games > Quake ][.\n"
    q2_runme
}

# Quake ]I[

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

q3_generate_icon() {
    if [ "$(getconf LONG_BIT)" == "64" ]; then
        BINARY_URL="quake3e.aarch64"
    else
        if is_vulkan_installed; then
            BINARY_URL="quake3e-vulkan"
        else
            BINARY_URL="quake3e-gl"
        fi
    fi
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/quake3.desktop ]]; then
        cat <<EOF >~/.local/share/applications/quake3.desktop
[Desktop Entry]
Name=Quake ]I[
Exec=${INSTALL_DIR}/quake3/${BINARY_URL}
Icon=${INSTALL_DIR}/quake3/icon.png
Path=${INSTALL_DIR}/quake3/
Type=Application
Comment=Quake III Arena is a 1999 multiplayer-focused first-person shooter developed by id Software. It is the third game in the Quake series; it differs from previous games by excluding a story-based single-player mode
Categories=Game;ActionGame;
EOF
    fi
}

q3_compile() {
    install_packages_if_missing "${Q3_PACKAGES_DEV[@]}"
    mkdir -p ~/sc && cd "$_" || exit 1
    echo -e "\nCloning and compiling Quake ]I[...\n"
    [[ ! -d ~/sc/Quake3e ]] && git clone "$Q3_SOURCE_CODE_URL"
    cd ~/sc/Quake3e/ || exit 1
    make -j"$(nproc)" OPTOPT="-march=armv8-a+crc -mtune=cortex-a72" BUILD_SERVER=0 USE_RENDERER_DLOPEN=0 USE_VULKAN=1
    echo -e "\nDone!. Binary files at build/release-linux-arm"
    exit_message
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

q3_magic_air_copy() {
    if ! exists_magic_file; then
        echo -e "\nNow copy data directory /baseq3 into $INSTALL_DIR/quake3 and enjoy :)"
        exit_message
    fi
    Q3_DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME_3")
    message_magic_air_copy "$VAR_DATA_NAME_3"
    download_and_extract "$Q3_DATA_URL" "$INSTALL_DIR"/quake3
}

q3_install() {
    q3_check_if_installed
    install_script_message
    echo "
Quake ]I[ for Raspberry Pi
==========================

 · Based on Quake3e engine.
 · OpenGL and Vulkan supported.
 · Some tweaks settings to get features like HDR, dynamic lights,...
 · High quality textures thanks to https://www.moddb.com/mods/high-quality-quake/downloads/hqq-high-quality-quake-v37-test
 · Config file at ~/.q3a/baseq3/q3config.cfg
 · Install path: $INSTALL_DIR/quake3
 · REMEMBER YOU NEED A LEGAL COPY OF THE GAME and copy /baseq3 directory inside $INSTALL_DIR/quake3
 · NOTE: It uses your OS resolution, even if you change it on config file.
"
    read -p "Press [Enter] to install the game..."
    q3_install_binary
    q3_generate_icon
    q3_magic_air_copy
    echo -e "\nDone!. You can play typing $INSTALL_DIR/quake3/quake3e or opening the Menu > Games > Quake ]I[.\n"
    q3_runme
}

menu() {
    while true; do
        dialog --clear \
            --title "[ Quake for Raspberry Pi ]" \
            --menu "Choose game:" 11 100 3 \
            Quake1 "Ranger travels across alternate dimensions to stop an enemy code-named 'Quake'" \
            Quake2 "It is not a direct sequel to Quake. The player is given mission-based objectives" \
            Quake3 "1999 multiplayer-focused fps that no have a story-based single-player mode" \
            Exit "Back to main menu" 2>"${INPUT}"

        menuitem=$(<"${INPUT}")

        case $menuitem in
        Quake1) clear && q1_install && return 0 ;;
        Quake2) clear && q2_install && return 0 ;;
        Quake3) clear && q3_install && return 0 ;;
        Exit) exit 0 ;;
        esac
    done
}

menu
