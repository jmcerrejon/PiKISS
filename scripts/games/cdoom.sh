#!/bin/bash
#
# Description : Zandronum and Crispy-Doom
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 2.0.6 (20/Aug/24)
# Tested      : Raspberry Pi 5
#
# shellcheck source=../helper.sh
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
readonly CRISPY_DOOM_PKG_64_BITS_URL="https://misapuntesde.com/rpi_share/crispy-doom_7.0.0_arm64.deb"
readonly CRISPY_DOOM_SOURCE="https://github.com/fabiangreffrath/crispy-doom"
readonly GZ_DOOM_SOURCE="https://github.com/coelckers/gzdoom"
readonly ZMUSIC_SOURCE="https://github.com/coelckers/ZMusic.git"
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
    rm -rf "$HOME/.local/share/crispy-doom"
    rm -f ~/.local/share/applications/crispy-hexen.desktop ~/.local/share/applications/crispy-strife.desktop ~/.local/share/applications/crispy-doom.desktop ~/.local/share/applications/crispy-heretic.desktop
    rm -f /usr/local/share/applications/io.github.fabiangreffrath.Doom.desktop /usr/local/share/applications/io.github.fabiangreffrath.Heretic.desktop /usr/local/share/applications/io.github.fabiangreffrath.Setup.desktop
    sudo rm -f /usr/share/applications/io.github.fabiangreffrath.Doom.desktop /usr/share/applications/io.github.fabiangreffrath.Heretic.desktop /usr/share/applications/io.github.fabiangreffrath.Hexen.desktop /usr/share/applications/io.github.fabiangreffrath.Strife.desktop /usr/share/applications/io.github.fabiangreffrath.Setup.desktop
}

remove_files() {
    rm -rf "$INSTALL_DIR"/wads
    sudo rm -rf /usr/bin/doom /usr/bin/heretic
    removeUnusedLinks
}

uninstall_crispy_doom() {
    read -p "Do you want to uninstall Crispy-Doom (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo apt remove -y crispy*
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
    echo -e "\nInstalling data files..."
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
    echo -e "\nDone! . Go to $(pwd)/src to run the binaries or type make install to install the app.\n"
    exit_message
}

modify_icons_crispy_doom() {
    local BASE_SHORTCUT_PATH="/usr/share/applications/io.github.fabiangreffrath"
    local DOOM_SHORTCUT_PATH="${BASE_SHORTCUT_PATH}.Doom.desktop"
    local HERETIC_SHORTCUT_PATH="${BASE_SHORTCUT_PATH}.Heretic.desktop"
    local HEXEN_SHORTCUT_PATH="${BASE_SHORTCUT_PATH}.Hexen.desktop"
    local STRIFE_SHORTCUT_PATH="${BASE_SHORTCUT_PATH}.Strife.desktop"

    echo -e "\nGenerating icon..."
    if [[ -e $DOOM_SHORTCUT_PATH ]]; then
        sudo sed -i "s|^Exec=crispy-doom.*|Exec=crispy-doom -iwad ${INSTALL_DIR}/wads/DOOM.WAD|" "$DOOM_SHORTCUT_PATH"
    fi
    if [[ -e $HERETIC_SHORTCUT_PATH ]]; then
        sudo sed -i "s|^Exec=crispy-heretic.*|Exec=crispy-heretic -iwad ${INSTALL_DIR}/wads/HERETIC.WAD|" "$HERETIC_SHORTCUT_PATH"
    fi
    if [[ -e $HEXEN_SHORTCUT_PATH ]]; then
        sudo sed -i "s|^Exec=crispy-hexen.*|Exec=crispy-hexen -iwad ${INSTALL_DIR}/wads/HEXEN.WAD|" "$HEXEN_SHORTCUT_PATH"
    fi
    if [[ -e $STRIFE_SHORTCUT_PATH ]]; then
        sudo sed -i "s|^Exec=crispy-strife.*|Exec=crispy-strife -iwad ${INSTALL_DIR}/wads/STRIFE.WAD|" "$STRIFE_SHORTCUT_PATH"
    fi
}

install_crispy() {
    local DOWNLOAD_URL=$CRISPY_DOOM_PKG_URL

    if command -v crispy-doom &>/dev/null; then
        echo -e "Crispy-Doom already installed!."
        uninstall_crispy_doom
        exit 1
    fi

    if is_userspace_64_bits; then
        DOWNLOAD_URL=$CRISPY_DOOM_PKG_64_BITS_URL
    fi

    install_script_message
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_install "$DOWNLOAD_URL"
    download_data_files "$INSTALL_DIR"
    modify_icons_crispy_doom
    echo -e "\nYou can play typing crispy-doom -iwad <WAD_FILE> or opening the Menu > Games > Crispy links.\nType crispy-{doom,heretic,hexen,strife}-setup for change settings."
    exit_message
}

compile_zmusic() {
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    git clone "$ZMUSIC_SOURCE" ZMusic && cd "$_" || exit 1
    mkdir -pv build && cd "$_" || exit 1
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$(pwd)/../build_install" ..
    make install
}

compile_gzdoom() {
    compile_zmusic
    install_packages_if_missing "${PACKAGES_DEV_GZ_DOOM[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    git clone "$GZ_DOOM_SOURCE" gzdoom && cd "$_" || exit 1
    wget -nc http://zdoom.org/files/fmod/fmodapi44464linux.tar.gz && tar -xvzf fmodapi44464linux.tar.gz -C .
    mkdir -pv build && cd "$_" || exit 1
    cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DC_INCLUDE_PATH="$HOME/sc/ZMusic/build_install/lib/" -DZMUSIC_INCLUDE_DIR=="$HOME/sc/ZMusic/build_install/include/" -DCMAKE_CXX_FLAGS="$HOME/sc/ZMusic/build_install/include/"
    make_with_all_cores
    printf "\nDone. If GZDoom complains you do not have any IWADs set up, make sure that you have your IWAD files placed in the same directory as GZDoom, in ~/.config/gzdoom/, DOOMWADDIR, or /usr/local/share/. Alternatively, you can edit ~/.config/gzdoom/gzdoom.ini or ~/ config/gzdoom/zdoom.ini to set the path for your IWADs."
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
Terminal=true
Categories=Game;
EOF
    fi
}

compile_zandronum() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    git clone --recursive "$ZANDRONUM_SOURCE_CODE_URL" zandronum && cd "$_" || exit 1
    mkdir build && cd "$_" || exit 1
    # TODO Returning valid CFLAGS for different RPi, Check https://github.com/ptitSeb/zandronum/blob/master/CMakeLists.txt
    CFLAGS="-fsigned-char -marm -march=armv8-a+crc -mtune=cortex-a72 -mfpu=neon-fp-armv8 -mfloat-abi=hard" CXXFLAGS="-fsigned-char" cmake .. -DNO_FMOD=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo -Wno-dev
    make_with_all_cores
    make_install_compiled_app
    echo -e "\nDone!. Check the code at $HOME/sc/zandronum"
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
            ZANDRONUM "(Recommended) Multiplayer oriented port for Doom,Heretic,Hexen,Strife..." \
            CRISPY_DOOM "Another engine with Doom,Heretic,Hexen,Strife support" \
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
