#!/bin/bash
#
# Description : Heroes of Might and Magic II/III
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.0 (12/Nov/20)
# Compatible  : Raspberry Pi 4
# Repository  : https://github.com/ihhub/fheroes2
# Help        : https://wiki.vcmi.eu/How_to_build_VCMI_(Linux)
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES_HMM2=(p7zip-full fluidr3mono-gm-soundfont fluid-soundfont-gm libsdl2-mixer-2.0-0 libsdl2-image-2.0-0 libsdl2-ttf-2.0-0)
readonly PACKAGES_HMM3=(p7zip-full libfuzzylite6.0 libminizip1 libsdl2-mixer-2.0-0 libsdl2-image-2.0-0 libsdl2-ttf-2.0-0 libboost-date-time1.67.0 libboost-filesystem1.67.0 libboost-locale1.67.0 libboost-program-options1.67.0)
readonly PACKAGES_DEV_HMM2=(libsdl2-dev libsdl2-ttf-dev libsdl2-mixer-dev libsdl2-image-dev gettext)
readonly PACKAGES_DEV_HMM3=(cmake g++ libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev libsdl2-mixer-dev zlib1g-dev libavformat-dev libswscale-dev libboost-dev libboost-filesystem-dev libboost-system-dev libboost-thread-dev libboost-program-options-dev libboost-locale-dev qtbase5-dev)
readonly BINARY_URL_HMM2="https://misapuntesde.com/rpi_share/fheroes2_0.83_rpi.tar.gz"
readonly BINARY_URL_HMM3="https://e.pcloud.link/publink/show?code=XZ5G07ZQk5NOIq33z72LleFk4CdYHeRPG7V"
readonly SOURCE_CODE_URL_HMM2="https://github.com/ihhub/fheroes2"
readonly SOURCE_CODE_URL_HMM3="https://github.com/vcmi/vcmi"
readonly VAR_DATA_NAME_HMM2="HEROES_2"
readonly VAR_DATA_NAME_HMM3="HEROES_3"
INPUT=/tmp/temp.$$

hmm2_runme() {
    if [ ! -f "$INSTALL_DIR"/fheroes2/fheroes2 ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    echo
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/fheroes2 && ./fheroes2
    exit_message
}

hmm2_remove_files() {
    rm -rf "$INSTALL_DIR"/fheroes2 ~/.local/share/applications/fheroes2.desktop ~/.fheroes2
}

hmm2_uninstall() {
    if [[ ! -d "$INSTALL_DIR"/fheroes2 ]]; then
        return 0
    fi

    echo -e "Heroes of Might and Magic II already installed.\n"
    read -p "Do you want to uninstall it (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        hmm2_remove_files
        if [[ -e "$INSTALL_DIR"/fheroes2 ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

hmm2_generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/fheroes2.desktop ]]; then
        cat <<EOF >~/.local/share/applications/fheroes2.desktop
[Desktop Entry]
Name=Heroes of Might and Magic II (fheroes2)
Version=1.0
Type=Application
Comment=Free implementation of Heroes of Might and Magic II engine
Exec=${INSTALL_DIR}/fheroes2/fheroes2
Icon=${INSTALL_DIR}/fheroes2/icon.png
Path=${INSTALL_DIR}/fheroes2/
Terminal=false
Categories=Game;
EOF
    fi
}

hmm2_compile() {
    install_packages_if_missing "${PACKAGES_DEV_HMM2[@]}"
    mkdir -p "$HOME/sc" && cd "$_"
    git clone "$SOURCE_CODE_URL_HMM2" fheroes2 && cd "$_"
    export WITH_SDL2="ON" make_with_all_cores
    echo
    read -p "Do you want to install it globally (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo make install
    fi
    echo -e "\nDone!. Check the code at $HOME/sc/fheroes2."
    exit_message
}

get_demo() {
    echo -e "\nInstalling demo files...\n"
    cd "$INSTALL_DIR/fheroes2/script/demo"
    ./demo_linux.sh
}

hmm2_install() {
    local DATA_URL

    hmm2_uninstall

    install_script_message
    echo "
Heroes of Might and Magic II engine (fheroes2) for Raspberry Pi
===============================================================

 · Free implementation of Heroes of Might and Magic II engine.
 · F4: Full screen.
 · Still in heavy development, but playable.
"
    read -p "Press [Enter] to continue..."
    
    install_packages_if_missing "${PACKAGES_HMM2[@]}"
    download_and_extract "$BINARY_URL_HMM2" "$INSTALL_DIR"
    hmm2_generate_icon
    echo -e "\nDo you have data files set on the file res/magic-air-copy-pikiss.txt for Heroes of Might and Magic II?"
    read -p "(If not, demo version will be installed) (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME_HMM2")

        if ! message_magic_air_copy "$DATA_URL"; then
            echo -e "\nNow copy data directory into $INSTALL_DIR/fheroes2."
            return 0
        fi
        download_and_extract "$DATA_URL" "$INSTALL_DIR/fheroes2"
    else
        get_demo
    fi

    echo -e "\n\nDone!. You can play typing $INSTALL_DIR/fheroes2/fheroes2 or opening the Menu > Games > Heroes of Might and Magic II engine (fheroes2).\n"
    hmm2_runme
}

# Heroes 3

hmm3_runme() {
    if [ ! -f "$INSTALL_DIR"/vcmi/vcmiclient ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    echo
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/vcmi && ./vcmilauncher
    exit_message
}

hmm3_remove_files() {
    rm -rf "$INSTALL_DIR"/vcmi ~/.local/share/applications/vcmi.desktop ~/.config/vcmi ~/.config/VCMI\ Team 
}

hmm3_uninstall() {
    if [[ ! -d "$INSTALL_DIR"/vcmi ]]; then
        return 0
    fi

    echo -e "Heroes of Might and Magic III already installed.\n"
    read -p "Do you want to uninstall it (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        hmm3_remove_files
        if [[ -e "$INSTALL_DIR"/vcmi ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

hmm3_compile() {
    # NOTE: It requires a lot of memory. I couldn't get to work, even with ZRAM enabled :(
    install_packages_if_missing "${PACKAGES_DEV_HMM3[@]}"
    mkdir -p "$HOME/sc" && cd "$_"
    git clone -b develop --depth 1 --recursive "$SOURCE_CODE_URL_HMM3" vcmi && cd "$_"
    mkdir build && cd "$_"
    cmake ..
    make_with_all_cores
    echo
    read -p "Do you want to install it globally (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo make install
    fi
    echo -e "\nDone!. Check the code at $HOME/sc/vcmi."
    exit_message
}

hmm3_generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/vcmi.desktop ]]; then
        cat <<EOF >~/.local/share/applications/vcmi.desktop
[Desktop Entry]
Name=Heroes of Might and Magic III (vcmi)
Version=1.0
Type=Application
Comment=Free implementation of Heroes of Might and Magic III engine
Exec=${INSTALL_DIR}/vcmi/vcmiclient
Icon=${INSTALL_DIR}/vcmi/icon.png
Path=${INSTALL_DIR}/vcmi/
Terminal=false
Categories=Game;
EOF
    fi
}

hmm3_post_install() {
    cp -fr "$INSTALL_DIR/vcmi/vcmi" ~/.config
}

hmm3_install() {
    local DATA_URL

    hmm3_uninstall

    install_script_message
    echo "
Heroes of Might and Magic III engine (VCMI) for Raspberry Pi
============================================================

 · Thanks to @pale for his contribution.
 · Open-source project aiming to reimplement HMM3:WoG game engine.
 · I set the resolution to 1080, but you can change it and add Mods running $INSTALL_DIR/vcmi/vcmilauncher
 · pdf with a short tutorial inside $INSTALL_DIR/vcmi
 · EXPERIMENTAL: There is a bug: When you lose a battle, the game quit. I'm reporting to the team and I'll fix ASAP.
"
    read -p "Press [Enter] to continue..."
    
    install_packages_if_missing "${PACKAGES_HMM3[@]}"
    download_and_extract "$BINARY_URL_HMM3" "$INSTALL_DIR"
    hmm3_generate_icon
    hmm3_post_install

    echo
    read -p "Do you have data files set on the file res/magic-air-copy-pikiss.txt for Heroes of Might and Magic III? (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME_HMM3")

        if ! message_magic_air_copy "$DATA_URL"; then
            echo -e "\nNow copy Data, Maps and Mp3 directories into $INSTALL_DIR/vcmi."
            return 0
        fi
        download_and_extract "$DATA_URL" "$INSTALL_DIR/vcmi"
    else
        echo -e "\nNow copy Data, Maps and Mp3 directories into $INSTALL_DIR/vcmi."
    fi

    hmm3_runme
}

menu() {
    while true; do
        dialog --clear \
            --title "[ Heroes of Might and Magic ]" \
            --menu "Choose the engine:" 11 100 3 \
            fheroes2 "Free implementation of Heroes of Might and Magic II engine" \
            VCMI "(EXPERIMENTAL) Open-source project aiming to reimplement HMM3:WoG game engine" \
            Exit "Back to main menu" 2>"${INPUT}"

        menuitem=$(<"${INPUT}")

        case $menuitem in
        fheroes2) clear && hmm2_install && return 0 ;;
        VCMI) clear && hmm3_install && return 0 ;;
        Exit) exit 0 ;;
        esac
    done
}

menu