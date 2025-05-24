#!/bin/bash
#
# Description : Flycast Dreamcast Emulator
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.1 (25/Sep/22)
# Links       : https://archive.org/download/DreamcastSelfBoot
#
. ../helper.sh || . ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly PROYECT_NAME="flycast"
readonly BASE_DIR="$HOME/games"
readonly INSTALL_DIR="$BASE_DIR/$PROYECT_NAME"
readonly CONFIG_DIR="$HOME/.config/$PROYECT_NAME"
readonly SHARE_DIR="$HOME/.local/share/$PROYECT_NAME"
readonly CONFIG_FILE_NAME="emu.cfg"
readonly PACKAGES=(libminiupnpc17 libzip4)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/flycast-rpi-all.tar.gz"
readonly SOURCE_CODE_URL="https://github.com/flyinghead/flycast"
readonly GAME_URL="http://volgarr.rkd.zone/VolgarrDC_BIG_2015-10-15.cdi.zip"
readonly BIOS_CODE_NAME="DREAMCAST_BIOS_URL"

uninstall() {
    echo -e "Uninstall Flycast?\nNOTE: All installed files/cartridge/save games will be erased."
    read -p "Are you sure (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR" "$SHARE_DIR" ~/.config/flycast ~/.local/share/applications/flycast.desktop
        if [[ -e $INSTALL_DIR ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d $INSTALL_DIR ]]; then
    echo -e "Flycast already installed.\n"
    uninstall
    exit 1
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/flycast.desktop ]]; then
        cat <<EOF >~/.local/share/applications/flycast.desktop
[Desktop Entry]
Name=Flycast
Type=Application
Comment=Flycast is a multi-platform Sega Dreamcast, Naomi, Naomi 2, and Atomiswave emulator
Exec=${INSTALL_DIR}/run.sh
Icon=${INSTALL_DIR}/shell/linux/flycast.png
Path=${INSTALL_DIR}/
Terminal=false
Categories=Game;Emulator;
EOF
    fi
}

install_bios() {
    echo "
======================
= BiOS for emulator  =
======================

WARNING!: You need the BiOS files (In some countries the laws may consider it pirate software).
"
    read -p "Do you want PiKISS download it for you? (y/N) " response
    if [[ $response =~ [Yy] ]]; then
        check_additional_file
        DATA_URL=$(extract_path_from_res "$BIOS_CODE_NAME")
        if [[ $DATA_URL != "" ]]; then
            echo -e "\nDownloading BiOS files..."
            download_and_extract "$DATA_URL" "$SHARE_DIR"
        else
            echo -e "\nSorry, I can't find the BiOS files. Try to download it manually."
        fi
    fi
}

copy_config_file() {
    echo -e "\nCopying config files..."
    mkdir -p "$CONFIG_DIR"
    cp -r "$INSTALL_DIR/$CONFIG_FILE_NAME" "$CONFIG_DIR"
}

download_game() {
    download_and_extract "$GAME_URL" "$INSTALL_DIR"
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$BASE_DIR"
    copy_config_file
    generate_icon
    download_game
    install_bios

    echo -e "\nDone!. To play, on Desktop Menu > games or $INSTALL_DIR/run.sh\n"
    read -p "Press [Enter] to go back to the menu..."
}

install_script_message
echo "
Flycast Dreamcast Emulator
==========================

 · Version v2.0. | All credits goes to Foxhound311.
 · Game included: Volgaar the Viking.
 · Install/Games path: $INSTALL_DIR
 · Put the BIOS in $SHARE_DIR
 · More Info: $SOURCE_CODE_URL
 · Toggle fullscreen/windowed mode: ALT + ENTER twice (very unstable).
 · I don't know how to close the emulator. Toggle windowed mode and close it :P.
 · flycast wiki: https://github.com/TheArcadeStriker/flycast-wiki/wiki
 · Check Homebrew games: https://en.wikipedia.org/wiki/List_of_Dreamcast_homebrew_games
 · Compatibility list: https://newflycast.rinnegatamante.it
 · Supports the following:
   · SEGA Dreamcast games (CHD, CDI, GDI, CUE) including games based on Windows CE
   · SEGA NAOMI 1/2 games (.zip, .7z, .dat/.lst)
   · SEGA NAOMI GD-ROM games (.zip, .7z, .dat/.lst and .chd)
   · Sammy Atomiswave games (.zip, .7z)
"

install
