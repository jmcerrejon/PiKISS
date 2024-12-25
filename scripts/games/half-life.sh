#!/bin/bash
#
# Description : Xash3D-fwgs (AKA Half Life) & Source Engine (HL2) installer for Raspberry Pi
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 2.0.0 (25/Dec/24)
# Tested      : Raspberry Pi 5
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly BIN_GAME_DIR="$INSTALL_DIR/xash3d"
readonly BIN_GAME_SOURCE_DIR="$INSTALL_DIR/hl2"
readonly PACKAGES_DEV=(libsdl2-dev build-essential pkg-config ccache libbz2-dev libcurl4-gnutls-dev)
readonly PACKAGES_SOURCE_DEV=(git-all build-essential pkg-config ccache libsdl2-dev libfontconfig1-dev libopenal-dev libjpeg-dev libpng-dev libcurl4-gnutls-dev libbz2-dev libedit-dev)
readonly BINARY_XASH_64_BITS_URL="https://misapuntesde.com/rpi_share/xash3d-hlsdk-aarch64.tar.gz"
readonly BINARY_SOURCE_64_BITS_URL="https://misapuntesde.com/rpi_share/source-eng-hl2-aarch64.tar.gz"
readonly HQ_HL_TEXTURE_PACK_URL="https://gamebanana.com/dl/265907"
readonly SOURCE_CODE_XASH_FWGS_URL="https://github.com/FWGS/xash3d-fwgs"
readonly SOURCE_CODE_HL2_URL="https://github.com/nillerusr/source-engine"
readonly SOURCE_CODE_HLSDK_URL="https://github.com/FWGS/hlsdk-portable"
readonly VAR_HL1_DATA_NAME="HALF_LIFE"
readonly VAR_HL2_DATA_NAME="HALF_LIFE_2"
tempfile=$(mktemp) || tempfile=/tmp/test$$
INPUT=/tmp/menu.sh.$$
trap 'rm -f $INPUT' EXIT

runme_xash() {
    read -p "Press [ENTER] to run the game..."
    cd "$BIN_GAME_DIR" && ./xash3d
    echo
    exit_message
}

runme_source_engine() {
    read -p "Press [ENTER] to run the game..."
    cd "$BIN_GAME_SOURCE_DIR" && ./launcher.sh
    echo
    exit_message
}

uninstall_xash() {
    read -p "Do you want to uninstall Half-Life (y/N)? " response
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

uninstall_source_engine() {
    read -p "Do you want to uninstall Half-Life 2 (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$BIN_GAME_SOURCE_DIR" ~/.local/share/applications/source_engine.desktop
        if [[ -d $BIN_GAME_SOURCE_DIR ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

generate_icon_xash() {
    if [[ ! -e ~/.local/share/applications/xash3d.desktop ]]; then
        echo -e "\nGenerating icon..."
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

generate_icon_source_engine() {
    if [[ ! -e ~/.local/share/applications/source_hl2.desktop ]]; then
        echo -e "\nGenerating icon..."
        cat <<EOF >~/.local/share/applications/source_hl2.desktop
[Desktop Entry]
Name=Half Life 2
Exec=${INSTALL_DIR}/hl2/launcher.sh
Icon=${INSTALL_DIR}/hl2/Icon.svg
Path=${INSTALL_DIR}/hl2/
Type=Application
Terminal=true
Comment=Players assume the role of Gordon Freeman again, this time in a dystopian Earth infested by an alien empire known as the Combine.
Categories=Game;ActionGame;
EOF
    fi
}

post_install_HL1() {
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
}

download_data_files_HL1() {
    DATA_URL=$(extract_path_from_file "$VAR_HL1_DATA_NAME")
    message_magic_air_copy "$VAR_HL1_DATA_NAME"
    download_and_extract "$DATA_URL" "$BIN_GAME_DIR"
}

compile_source_engine() {
    install_packages_if_missing "${PACKAGES_SOURCE_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || return 1
    git clone --recursive --depth 1 "$SOURCE_CODE_HL2_URL" hl2 && cd "$_" || return 1
    ./waf configure -T release -j "$(nproc)" --prefix=hl2 --build-games=hl2 --disable-warns
    echo -e "\nCompiling, please wait (~20 minutes on RPi 5)..."
    ./waf build -p -v
    ./waf install --destdir="/hl2"
    echo -e "\nDone!. Check $BIN_GAME_SOURCE_DIR directory."
}

compile_hlsdk() {
    mkdir -p "$HOME/sc" && cd "_$" || return 1
    git clone --recursive "$SOURCE_CODE_HLSDK_URL" hlsdk && cd "$_" || return 1
    ./waf configure -T release -8 -j "$(nproc)"
    ./waf build
    ./waf install --destdir="$BIN_GAME_DIR"
    echo -e "\nDone!. Check $BIN_GAME_DIR directory."
}

compile_xash() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "_$" || return 1
    git clone --recursive "$SOURCE_CODE_XASH_FWGS_URL" xash3d && cd "$_" || return 1
    # NOTE It fails If I add: --enable-static-binary
    # If you get New game option greyes out/disabled, you need to copy the /dlls from hlsdk directory inside $$HOME/games/xash3d
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

install_xash() {
    if [[ -d $BIN_GAME_DIR ]]; then
        echo -e "Half-Life already installed.\n"
        uninstall_xash
        exit 0
    fi
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

    download_and_extract "$BINARY_XASH_64_BITS_URL" "$INSTALL_DIR"
    generate_icon_xash

    if ! exists_magic_file; then
        echo -e "\nNow copy the /valve directory inside $BIN_GAME_DIR and enjoy :)"
        exit_message
    fi

    download_data_files_HL1
    post_install_HL1
    echo -e "\nDone!."
    runme_xash
}

install_source_engine() {
    if [[ -d $BIN_GAME_SOURCE_DIR ]]; then
        echo -e "Half-Life 2 already installed.\n"
        uninstall_source_engine
        exit 0
    fi
    install_script_message
    echo "
Half Life 2
===========

 · Based on engine: ${SOURCE_CODE_HL2_URL}
 · Thanks to Lohann Paterno Coutinho and other participants for the help.
 · Better experience with 720p resolution.
 · You need to have a legal copy of the game from Steam.

 · IMPORTANT!: Run the file ./launcher.sh or click on Menu > Game > Half-Life 2 on Desktop to download the game data files from your Steam account and play. This process works exclusively for a specific version of game data files, so ensure you have your Steam credentials ready before proceeding. PiKISS does not store any of your credentials. Check out the project https://github.com/SteamRE/DepotDownloader for more information.
"
    read -p "Press [ENTER] to continue..."

    download_and_extract "$BINARY_SOURCE_64_BITS_URL" "$INSTALL_DIR"
    generate_icon_source_engine

    echo -e "\nDone!\n"
    runme_source_engine
}

menu() {
    while true; do
        dialog --clear \
            --title "[ Half Life ]" \
            --menu "Select from the list:" 11 68 3 \
            XASH "Half Life 1" \
            SOURCE "Half Life 2" \
            EXIT "Exit" 2>"${tempfile}"

        menuitem=$(<"${tempfile}")

        case $menuitem in
        XASH) clear && install_xash ;;
        SOURCE) clear && install_source_engine ;;
        EXIT) exit ;;
        esac
    done
}

if ! is_userspace_64_bits; then
    echo -e "\nSorry, only 64-bit OS supported."
    exit_message
fi

menu
