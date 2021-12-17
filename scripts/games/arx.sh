#!/bin/bash
#
# Description : Arx Libertatis (AKA Arx Fatalis)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.11 (17/Dec/21)
# Compatible  : Raspberry Pi 4 (tested)
#
# Help        : https://wiki.arx-libertatis.org/Downloading_and_Compiling_under_Linux
# For fans    : https://www.reddit.com/r/ArxFatalis/ | https://www.moddb.com/mods/arx-neuralis/downloads/arx-neuralis
#

. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libglew-dev)
readonly PACKAGES_DEV=(zlib1g-dev libfreetype6-dev libopenal1 libopenal-dev mesa-common-dev libgl1-mesa-dev libboost-dev libepoxy-dev libglm-dev libcppunit-dev libglew-dev libsdl2-dev)
readonly CONFIG_DIR="$HOME/.local/share/arx"
readonly BINARY_URL="https://www.littlecarnage.com/arx_rpi2.tar.gz"
readonly SOURCE_CODE_URL="https://github.com/ptitSeb/ArxLibertatis.git"
readonly SOURCE_CODE_OFFICIAL_URL="https://github.com/arx/ArxLibertatis.git" # Doesn't work for now
readonly ICON_URL="https://github.com/arx/ArxLibertatisData/blob/master/icons/arx-libertatis-32.png?raw=true"
readonly VAR_DATA_NAME="ARX_FATALIS"
DATA_URL="https://e.pcloud.link/publink/show?code=XZOsaZFJFHKEmMiHQtMyFw7ESWemvYz8xV"
INPUT=/tmp/arx.$$

runme() {
    if [ ! -f "$INSTALL_DIR"/arx/arx ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    echo
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/arx && ./arx
    exit_message
}

remove_files() {
    rm -rf ~/.local/share/applications/arx.desktop ~/.local/share/arx "$CONFIG_DIR"/arx-libertatis-32.png \
        "$INSTALL_DIR"/arx /usr/local/share/blender/scripts/addons/arx /usr/local/share/games/arx
}

uninstall() {
    read -p "Do you want to uninstall Arx Libertatis (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/arx ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/arx ]]; then
    echo -e "Arx Libertatis already installed.\n"
    uninstall
    exit 1
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    mkdir -p "$CONFIG_DIR"
    wget -q "$ICON_URL" -O "$CONFIG_DIR"/arx-libertatis-32.png
    if [[ ! -e ~/.local/share/applications/arx.desktop ]]; then
        cat <<EOF >~/.local/share/applications/arx.desktop
[Desktop Entry]
Name=Arx Fatalis (AKA Arx Libertatis)
Exec=${INSTALL_DIR}/arx/arx
Icon=${CONFIG_DIR}/arx-libertatis-32.png
Type=Application
Comment=Arx Fatalis is set on a world whose sun has failed, forcing the above-ground creatures to take refuge in caverns.
Categories=Game;ActionGame;
EOF
    fi
}

fix_libndi() {
    echo -e "\nFixing library libndi.so\n"
    sudo rm -f /usr/lib/libndi.so
    sudo ln -r -s /usr/lib/libndi.so.4.0.0 /usr/lib/libndi.so
    sudo rm -f /usr/lib/libndi.so.4
    sudo ln -r -s /usr/lib/libndi.so.4.0.0 /usr/lib/libndi.so.4
}

fix_libGLEW1.7() {
    if [[ -f /usr/lib/arm-linux-gnueabihf/libGLEW.so.1.7 ]]; then
        return 0
    fi

    echo -e "\nLinking libGLEW.so -> libGLEW.so.1.7\n"
    sudo ln -s /usr/lib/arm-linux-gnueabihf/libGLEW.so /usr/lib/arm-linux-gnueabihf/libGLEW.so.1.7
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    fix_libndi
    mkdir -p ~/sc && cd "$_" || exit 1
    git clone "$SOURCE_CODE_URL" arx && cd "$_" || exit 1
    mkdir build && cd "$_" || exit 1
    CFLAGS="-fsigned-char -marm -march=armv8-a+crc -mtune=cortex-a72 -mfpu=neon-fp-armv8 -mfloat-abi=hard" CXXFLAGS="-fsigned-char" cmake .. -DBUILD_TOOLS=off -DBUILD_IO_LIBRARY=off -DBUILD_CRASHREPORTER=off -DICON_TYPE=none

    if [[ -f ~/sc/arx/build/CMakeFiles/CMakeError.log ]]; then
        echo -e "\n\nERROR!!. I can't continue with the command make. Check ~/sc/arx/build/CMakeFiles/CMakeError.log\n"
        exit 1
    fi
    make -j"$(getconf _NPROCESSORS_ONLN)"
}

install_binaries() {
    echo -e "\nInstalling binary files..."
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    rm "$INSTALL_DIR/Arx Fatalis.sh"
    chmod +x "$INSTALL_DIR"/arx/arx*
    fix_libGLEW1.7
}

end_message() {
    echo -e "\nDone!. Click on Menu > Games > Arx Libertatis."
    runme
}

download_data_files() {
    if exists_magic_file; then
        DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME")
    fi
    message_magic_air_copy "$VAR_DATA_NAME_EN"
    download_and_extract "$DATA_URL" ~
}

install() {
    mkdir -p "$INSTALL_DIR"
    install_packages_if_missing "${PACKAGES[@]}"
    install_binaries
    generate_icon
    download_data_files
    end_message
}

install_script_message
echo "
Install Arx Libertatis (Port of Arx Fatalis)
============================================
 · Install path: $INSTALL_DIR/arx
 · Demo version will be installed If it's not provided the game data files path in $PIKISS_MAGIC_AIR_COPY_PATH.
 · NOTE: It's NOT the latest compiled from source. This binary comes from https://www.littlecarnage.com/
"
read -p "Press [Enter] to continue..."
install
