#!/bin/bash
#
# Description : Xash3D-fwgs (AKA Half Life)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 2.0.0 (10/Jul/24)
# Tested      : Raspberry Pi 5
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly BIN_GAME_DIR="$INSTALL_DIR/xash3d"
readonly PACKAGES_DEV=(libsdl2-dev)
readonly BINARY_64_BITS_URL="https://misapuntesde.com/rpi_share/xash3d-hlsdk-aarch64.tar.gz"
readonly HQ_TEXTURE_PACK_URL="https://gamebanana.com/dl/265907"
readonly SOURCE_CODE_XASH_FWGS_URL="https://github.com/FWGS/xash3d-fwgs"
readonly SOURCE_CODE_HLSDK_URL="https://github.com/FWGS/hlsdk-portable"
readonly ES_TRANSLATION_URL="https://misapuntesde.com/rpi_share/hl-sp-patch.tar.gz"
readonly VAR_DATA_NAME="HALF_LIFE"

runme() {
    read -p "Press [ENTER] to run the game..."
    cd "$BIN_GAME_DIR" && ./xash3d
    echo
    exit_message
}

uninstall() {
    read -p "Do you want to uninstall Half Life (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$BIN_GAME_DIR" ~/.local/share/applications/xash3d.desktop
        if [[ -d $BIN_GAME_DIR ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d $BIN_GAME_DIR ]]; then
    echo -e "Half Life already installed.\n"
    uninstall
    exit 0
fi

generate_icon() {
    if [[ ! -e ~/.local/share/applications/xash3d.desktop ]]; then
        cat <<EOF >~/.local/share/applications/xash3d.desktop
[Desktop Entry]
Name=Half Life
Exec=${INSTALL_DIR}/xash3d/xash3d
Icon=${INSTALL_DIR}/xash3d/hl.png
Path=${INSTALL_DIR}/xash3d/
Type=Application
Comment=Players assume the role of Gordon Freeman, a scientist who must find his way out of the Black Mesa Research Facility after it is invaded by aliens
Categories=Game;ActionGame;
EOF
    fi
}

post_install() {
    local VALVE_DIR_PATH="$BIN_GAME_DIR"/valve
    local CONFIG_FILE_PATH="$BIN_GAME_DIR"/config.cfg

    if [[ -f $CONFIG_FILE_PATH ]] && [[ -d $VALVE_DIR_PATH ]]; then
        echo -e "\nCopying tweaked config.cfg..."
        cp -f "$CONFIG_FILE_PATH" "$VALVE_DIR_PATH"
    fi

    # download_and_extract "$HQ_TEXTURE_PACK_URL" "$BIN_GAME_DIR"
    # mv -f "$BIN_GAME_DIR"/high-definition_resourced/hl1/* "$VALVE_DIR_PATH"
    # rm -rf "$BIN_GAME_DIR"/high-definition_resourced/

    if [[ -d $BIN_GAME_DIR/valve_hd ]] && [[ -d $VALVE_DIR_PATH ]]; then
        echo -e "\nCopying HD textures..."
        cp -f "$BIN_GAME_DIR"/valve_hd/* "$VALVE_DIR_PATH"
    fi

    # if [[ $(get_keyboard_layout) == "es" ]]; then
    #     echo
    #     echo "Detected Latin/Spanish user. Applying translation..."
    #     download_and_extract "$ES_TRANSLATION_URL" "$BIN_GAME_DIR"
    # fi
}

download_data_files() {
    DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME")
    message_magic_air_copy "$VAR_DATA_NAME"
    download_and_extract "$DATA_URL" "$BIN_GAME_DIR"
}

compile_hlsdk() {
    mkdir -p "$HOME/sc" && cd "_$" || return 1
    git clone --recursive "$SOURCE_CODE_HLSDK_URL" hlsdk && cd "$_" || return 1
    ./waf configure -T release -8 -j "$(nproc)"
    ./waf build
    ./waf install --destdir="$BIN_GAME_DIR"
    echo -e "\nDone!. Check $BIN_GAME_DIR directory."
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "_$" || return 1
    git clone --recursive "$SOURCE_CODE_XASH_FWGS_URL" xash3d && cd "$_" || return 1
    # NOTE It fails If I add: --enable-static-binary
    # If you get New game option greyes out/disabled, you need to copy the /dlls from hlsdk directory inside $BIN_GAME_DIR
    # For debug mode, you can use the parameter ./xash3d -log -dev 2
    ./waf configure -T release -8 -j "$(nproc)" --enable-lto --enable-poly-opt --disable-werror --enable-all-renderers --disable-utils-mdldec --enable-static-gl
    ./waf build
    ./waf install --destdir="$BIN_GAME_DIR"
    echo -e "\nDone!. Check $BIN_GAME_DIR directory."
    read -p "Do you want to compile HLSDK (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        compile_hlsdk
    fi
    exit_message
}

install() {
    local DATA_URL
    local INSTALL_BIN_PATH=$BINARY_64_BITS_URL

    if ! is_userspace_64_bits; then
        echo -e "\nSorry, only 64-bit OS is supported."
        exit_message
    fi

    download_and_extract "$INSTALL_BIN_PATH" "$INSTALL_DIR"
    generate_icon

    if ! exists_magic_file; then
        echo -e "\nNow copy the /valve directory inside $BIN_GAME_DIR and enjoy :)"
        exit_message
    fi

    download_data_files
    post_install
    echo -e "\nDone!."
    runme
}

install_script_message
echo "
Half Life
=========

 · Based on engine: ${SOURCE_CODE_XASH_FWGS_URL}
 · REMEMBER YOU NEED A LEGAL COPY OF THE GAME and copy /valve directory inside $BIN_GAME_DIR.
 · Overwrite /valve with /valve_hd to get HD textures for some models, materials & HQ sounds.
 · To play, when installed use Menu > Games > Half-Life or $BIN_GAME_DIR/xash3d
"
read -p "Press [ENTER] to continue..."

install
