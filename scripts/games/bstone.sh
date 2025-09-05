#!/bin/bash
#
# Description : Bstone: A source port of Blake Stone: Aliens Of Gold and Blake Stone: Planet Strike.
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.3 (05/Sep/25)
# Tested      : Raspberry Pi 5
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES_DEV=(libsdl2-dev)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/bstone-1.2.12-rpi.tar.gz"
readonly SOURCE_CODE_URL="https://github.com/bibendovsky/bstone"
readonly AOG_FULL_DATA_PATH="$INSTALL_DIR/bstone/data-full/aog"
readonly AOG_SHARE_DATA_PATH="$INSTALL_DIR/bstone/data-share/aog"
readonly PS_FULL_DATA_PATH="$INSTALL_DIR/bstone/data-full/pstrike"
readonly CONFIG_DIR="$HOME/.local/share/bibendovsky/bstone"
readonly VAR_DATA_NAME="BSTONE"

runme() {
    local DATA_DIR
    [[ -e ~/.local/share/applications/aog-full.desktop ]] && DATA_DIR="$AOG_FULL_DATA_PATH" || DATA_DIR="$AOG_SHARE_DATA_PATH"
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/bstone && ./run.sh "$DATA_DIR"
    echo
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/bstone "$CONFIG_DIR" ~/.local/share/applications/aog-full.desktop ~/.local/share/applications/aog-share.desktop ~/.local/share/applications/ps-full.desktop
}

uninstall() {
    read -p "Do you want to uninstall Blake Stone (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/bstone ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/bstone ]]; then
    echo -e "Blake Stone already installed.\n"
    uninstall
    exit 0
fi

generate_icon_AOG_FULL() {
    if [[ ! -e ~/.local/share/applications/aog-full.desktop ]]; then
        cat <<EOF >~/.local/share/applications/aog-full.desktop
[Desktop Entry]
Name=Blake Stone Aliens of Gold (Full)
Exec=${INSTALL_DIR}/bstone/run.sh ${AOG_FULL_DATA_PATH}
Path=${INSTALL_DIR}/bstone/
Icon=${INSTALL_DIR}/bstone/icon-aog.png
Type=Application
Comment=Year 2140. Blake Stone, an agent of the British Intelligence, must to investigate and eliminate the threat of Dr. Pyrus Goldfire
Categories=Game;ActionGame;
EOF
    fi
}
generate_icon_AOG_SHARE() {
    if [[ ! -e ~/.local/share/applications/aog-share.desktop ]]; then
        cat <<EOF >~/.local/share/applications/aog-share.desktop
[Desktop Entry]
Name=Blake Stone Aliens of Gold (Shareware)
Exec=${INSTALL_DIR}/bstone/run.sh ${AOG_SHARE_DATA_PATH}
Path=${INSTALL_DIR}/bstone/
Icon=${INSTALL_DIR}/bstone/icon-aog.png
Type=Application
Comment=Year 2140. Blake Stone, an agent of the British Intelligence, must to investigate and eliminate the threat of Dr. Pyrus Goldfire
Categories=Game;ActionGame;
EOF
    fi
}

generate_icon_PS_FULL() {
    if [[ ! -e ~/.local/share/applications/ps-full.desktop ]]; then
        cat <<EOF >~/.local/share/applications/ps-full.desktop
[Desktop Entry]
Name=Blake Stone Planet Strike (Full)
Exec=${INSTALL_DIR}/bstone/run.sh ${PS_FULL_DATA_PATH}
Path=${INSTALL_DIR}/bstone/
Icon=${INSTALL_DIR}/bstone/icon-ps.png
Type=Application
Comment=Following Pyrus Goldfire's escape at the end of Aliens of Gold, British Intelligence initiated a large-scale search to capture him
Categories=Game;ActionGame;
EOF
    fi
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    echo -e "\nCloning and compiling...\n"
    [[ ! -d $HOME/sc/bstone ]] && git clone "$SOURCE_CODE_URL" bstone
    cd "$HOME/sc/bstone" || exit 1
    mkdir -p build && cd "$_" || exit 1
    cmake ../src -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_MODULE_PATH=../cmake -DCMAKE_INSTALL_PREFIX=~/sc/bstone/build/install -DBSTONE_USE_PCH=ON -DBSTONE_USE_STATIC_LINKING=ON -DBSTONE_USE_MULTI_PROCESS_COMPILATION=ON
    make_with_all_cores
    echo -e "\nDone!."
    exit_message
}

download_data_files() {
    DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME")
    message_magic_air_copy "$VAR_DATA_NAME"
    download_and_extract "$DATA_URL" "$INSTALL_DIR/bstone"
}

install() {
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    [[ ! -d "$CONFIG_DIR" ]] && mkdir -p "$CONFIG_DIR"
    cp "$INSTALL_DIR"/bstone/bstone_config.txt "$CONFIG_DIR"

    if exists_magic_file; then
        download_data_files
        generate_icon_AOG_FULL
        generate_icon_PS_FULL
        echo -e "\nDone!."
        runme
    fi

    generate_icon_AOG_SHARE
    echo -e "\nDone!."
    runme
}

echo "
Install Blake Stone on Raspberry Pi
===================================

 · Optimized for Raspberry Pi 4.
 · Based on engine at ${SOURCE_CODE_URL}
 · NOTE: This engine has a bug on 32 bits. Don't change the video renderer mode.
 · WASD: Movement | Cursor: Rotate | Space: Open | Ctrl: Fire | TAB: HUB
 · Aliens of Gold Maps: https://jalu.ch/misc/bstone/
"
read -p "Continue? (Y/n) " response
if [[ $response =~ [Nn] ]]; then
    exit_message
fi

install
