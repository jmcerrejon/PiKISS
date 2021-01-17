#!/bin/bash
#
# Description : Zandronum and Crispy-Doom
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 2.0.0 (17/Jan/21)
# Compatible  : Raspberry Pi 4 (tested)
#
# HELP        : To compile crispy-doom, follow the instructions at https://github.com/fabiangreffrath/crispy-doom
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(timidity libsdl2-net-2.0-0 libsdl2-net-dev libsdl2-mixer-2.0-0)
readonly PACKAGES_ZANDRONUM=(libglu1-mesa)
readonly PACKAGES_DEV_CRISPY=(build-essential automake git timidity libsdl2-net-2.0-0 libsdl2-net-dev libsdl2-mixer-dev)
readonly PACKAGES_DEV_GZ_DOOM=(g++ make cmake libsdl2-dev git zlib1g-dev libbz2-dev libjpeg-dev libfluidsynth-dev libgme-dev libopenal-dev libmpg123-dev libsndfile1-dev libgtk-3-dev timidity nasm libgl1-mesa-dev tar libsdl1.2-dev libglew-dev)
readonly PACKAGES_DEV=(g++ make cmake libsdl2-dev git zlib1g-dev libbz2-dev libjpeg-dev libfluidsynth-dev libgme-dev libopenal-dev libmpg123-dev libsndfile1-dev libgtk-3-dev timidity nasm libgl1-mesa-dev tar libsdl1.2-dev libglew-dev libssl-dev)
readonly ZANDRONUM_BINARY_URL="https://misapuntesde.com/rpi_share/zandronum-rpi.tar.gz"
readonly ZANDRONUM_SOURCE_CODE_URL="https://github.com/ptitSeb/zandronum"
readonly CRISPY_DOOM_PKG_URL="https://misapuntesde.com/rpi_share/crispy_5-8.0_armhf.deb"
readonly CRISPY_DOOM_SOURCE="https://github.com/fabiangreffrath/crispy-doom.git"
readonly GZ_DOOM_SOURCE="https://github.com/drfrag666/gzdoom.git"
readonly # CHOCOLATE_DOOM="https://misapuntesde.com/rpi_share/chocolate_3-0_armhf.deb" # Future release?
readonly VAR_DATA_NAME="WADS"
DATA_URL="https://misapuntesde.com/rpi_share/wads-shareware.tar.gz"
INPUT=/tmp/doom.$$

runme() {
    [[ ! -e $INSTALL_DIR/zandronum/zandronum ]] && exit_message

    read -p "Do you want to play now (Y/n)? " response
    if [[ $response =~ [Nn] ]]; then
        exit_message
    fi
    cd "$INSTALL_DIR/zandronum" && ./zandronum
    exit_message
}

removeUnusedLinks() {
    rm -f ~/.local/share/applications/crispy-hexen.desktop ~/.local/share/applications/crispy-strife.desktop
    rm -f /usr/local/share/applications/io.github.fabiangreffrath.Doom.desktop /usr/local/share/applications/io.github.fabiangreffrath.Heretic.desktop /usr/local/share/applications/io.github.fabiangreffrath.Setup.desktop
    rm -f ~/.local/share/applications/crispy-doom.desktop
    rm -f ~/.local/share/applications/crispy-heretic.desktop
}

remove_files() {
    rm -rf "$INSTALL_DIR"/wads
    sudo rm -rf /usr/bin/doom /usr/bin/heretic
    removeUnusedLinks
}

uninstall_crispy_doom() {
    read -p "Do you want to uninstall Crispy-Doom (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo apt remove -y crispy
        remove_files
        if [[ -e /usr/local/bin/crispy-doom ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
}

uninstall_zandronum() {
    read -p "Do you want to uninstall Zandronum (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR/zandronum" ~/.local/share/applications/zandronum.desktop
        if [[ -e $INSTALL_DIR/zandronum ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
}

download_data_files() {
    echo -e "\nInstalling data files (Shareware WADs)..."
    if [[ $(extract_path_from_file "$VAR_DATA_NAME") != '' ]]; then
        DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME")
    fi
    download_and_extract "$DATA_URL" "$1"
}

compile_crispy_doom() {
    install_packages_if_missing "${PACKAGES_DEV_CRISPY[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    git clone "$CRISPY_DOOM_SOURCE" crispy-doom && cd "$_" || exit 1
    sudo apt build-dep crispy-doom
    autoreconf -fiv
    ./configure
    make_with_all_cores
    echo -e "\nDone! . Go to $(pwd) to run the binaries or type make install to install the app.\n"
}

generate_icon_crispy_doom() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/crispy-doom.desktop ]]; then
        cat <<EOF >~/.local/share/applications/crispy-doom.desktop
[Desktop Entry]
Name=Crispy Doom
Version=1.0
Type=Application
Comment=Limit-removing enhanced-resolution Doom source port
Exec=crispy-doom -iwad ${INSTALL_DIR}/wads/DOOM.WAD
Icon=crispy-doom
Terminal=false
Categories=Game;ActionGame;
EOF
    fi
    if [[ ! -e ~/.local/share/applications/crispy-heretic.desktop ]]; then
        cat <<EOF >~/.local/share/applications/crispy-heretic.desktop
[Desktop Entry]
Name=Crispy Heretic
Version=1.0
Type=Application
Comment=Limit-removing enhanced-resolution Doom source port
Exec=crispy-heretic -iwad ${INSTALL_DIR}/wads/HERETIC.WAD
Icon=crispy-doom
Terminal=false
Categories=Game;ActionGame;
EOF
    fi
}

install_crispy() {
    if [[ -e /usr/local/bin/crispy-doom ]]; then
        clear
        echo -e "Crispy-Doom already installed!."
        uninstall_crispy_doom
        exit 1
    fi
    local SHORTCUT_URL
    SHORTCUT_URL="https://misapuntesde.com/res/crispy_modified_link.zip"
    install_script_message
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_install "$CRISPY_DOOM_PKG_URL"
    removeUnusedLinks
    generate_icon_crispy_doom
    download_data_files "$INSTALL_DIR/wads"
    echo -e "\nYou can play typing crispy-doom <WAD_FILE> or opening the Menu > Games > Doom or Heretic."
    exit_message
}

compile_gzdoom() {
    install_packages_if_missing "${PACKAGES_DEV_GZ_DOOM[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    git clone "$GZ_DOOM_SOURCE" gzdoom && cd "$_" || exit 1
    wget -nc http://zdoom.org/files/fmod/fmodapi44464linux.tar.gz && tar -xvzf fmodapi44464linux.tar.gz -C .
    mkdir -pv build && cd "$_" || exit 1
    cmake .. -DNO_FMOD=ON
}

generate_icon_zandronum() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/zandronum.desktop ]]; then
        cat <<EOF >~/.local/share/applications/zandronum.desktop
[Desktop Entry]
Name=Zandronum
Version=1.0
Type=Application
Comment=Zandronum is a multiplayer oriented port, based off Skulltag, for Doom I/II and derivates
Exec=${INSTALL_DIR}/zandronum/zandronum
Icon=${INSTALL_DIR}/zandronum/icon.png
Path=${INSTALL_DIR}/zandronum/
Terminal=false
Categories=Game;
EOF
    fi
}

compile_zandronum() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    git clone --recursive "$GITHUB_URL" zandronum && cd "$_" || exit 1
    mkdir build && cd "$_" || exit 1
    # TODO Returning valid CFLAGS for different RPi, Check https://github.com/ptitSeb/zandronum/blob/master/CMakeLists.txt
    CFLAGS="-fsigned-char -marm -march=armv8-a+crc -mtune=cortex-a72 -mfpu=neon-fp-armv8 -mfloat-abi=hard" CXXFLAGS="-fsigned-char" cmake .. -DNO_FMOD=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo -Wno-dev
    make_with_all_cores "\nCompiling..."
    read -p "Do you want to install globally (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo make install
    fi
    echo -e "\nDone!. Check the code at $HOME/sc/MY_APP."
    exit_message
}

install_zandronum() {
    if [[ -e $INSTALL_DIR/zandronum/zandronum ]]; then
        clear
        echo -e "Zandronum already installed!."
        uninstall_zandronum
        exit 1
    fi
    install_script_message
    install_packages_if_missing "${PACKAGES_ZANDRONUM[@]}"
    download_and_extract "$ZANDRONUM_BINARY_URL" "$INSTALL_DIR"
    generate_icon_zandronum

    download_data_files "$INSTALL_DIR/zandronum"
    echo -e "\nYou can play typing $INSTALL_DIR/zandronum/zandronum or opening the Menu > Games > Zandronum."
    runme
}

menu() {
    while true; do
        dialog --clear \
            --title "[ DOOM'S ENGINE ]" \
            --menu "Select from the list:" 11 100 3 \
            ZANDRONUM "(Recommended) Multiplayer oriented port for Doom I/II,Heretic,Hexen,Strife..." \
            CRISPY_DOOM "Another engine with Doom + Heretic support" \
            Exit "Exit" 2>"${INPUT}"

        menuitem=$(<"${INPUT}")

        case $menuitem in
        ZANDRONUM) clear && install_zandronum ;;
        CRISPY_DOOM) clear && install_crispy ;;
        Exit) exit ;;
        esac
    done
}

menu
