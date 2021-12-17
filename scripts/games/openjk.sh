#!/bin/bash
#
# Description : OpenJK
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (17/Dec/21)
# Compatible  : Raspberry Pi 4 (tested)
#
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly BINARY_URL="https://misapuntesde.com/rpi_share/openjk-rpi.tar.gz"
readonly PACKAGES=(libpng12-0 libjpeg-dev zlib1g-dev)
readonly PACKAGES_DEV=(build-essential cmake libjpeg-dev libpng-dev zlib1g-dev libsdl2-dev)
readonly SOURCE_CODE_URL="https://github.com/JACoders/OpenJK.git"
readonly VAR_DATA_NAME="JEDI_ACADEMY"
readonly CODENAME=$(get_codename)

runme() {
    if [ ! -f "$INSTALL_DIR"/JediAcademy/openjk_sp.arm ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR"/JediAcademy && ./openjk_sp.arm
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/JediAcademy ~/.local/share/applications/JediAcademy.desktop ~/.local/share/applications/JediAcademySP.desktop ~/.local/share/openjk
}

uninstall() {
    read -p "Do you want to uninstall OpenJK (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/JediAcademy ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ "$CODENAME" == "buster" ]]; then
    echo -e "\nDetected Buster. This game is not ready for that version. Apologies. Maybe it's time to upgrade to Bullseye?."
    exit_message
fi

if [[ -d "$INSTALL_DIR"/JediAcademy ]]; then
    echo -e "OpenJK already installed.\n"
    uninstall
fi

generate_icons() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/JediAcademy.desktop ]]; then
        cat <<EOF >~/.local/share/applications/JediAcademy.desktop
[Desktop Entry]
Name=OpenJK (Multiplayer)
Exec=${INSTALL_DIR}/JediAcademy/openjk.arm
Icon=${INSTALL_DIR}/JediAcademy/icons/OpenJK_Icon_32.png
Path=${INSTALL_DIR}/JediAcademy/
Type=Application
Comment=Community effort to maintain and improve Jedi Academy (SP & MP) + Jedi Outcast (SP only) released by Raven Software
Categories=Game;ActionGame;
EOF
    fi

    if [[ ! -e ~/.local/share/applications/JediAcademySP.desktop ]]; then
        cat <<EOF >~/.local/share/applications/JediAcademySP.desktop
[Desktop Entry]
Name=OpenJK (Single Player)
Exec=${INSTALL_DIR}/JediAcademy/openjk_sp.arm
Icon=${INSTALL_DIR}/JediAcademy/icons/OpenJK_Icon_32.png
Path=${INSTALL_DIR}/JediAcademy/
Type=Application
Comment=Community effort to maintain and improve Jedi Academy (SP & MP) + Jedi Outcast (SP only) released by Raven Software
Categories=Game;ActionGame;
EOF
    fi
}

compile() {
    echo -e "\nInstalling dependencies (if proceed)...\n"
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    echo
    git clone "$SOURCE_CODE_URL" openjk && cd "$_" || exit 1
    echo -e "\n\nCompiling... Estimated time on RPi 4: ~7-10 min.\n"
    make_with_all_cores WITHOUT_GTK=1 POLYMER=1 USE_LIBVPX=0 HAVE_FLAC=0 OPTLEVEL=3 LTO=0 RENDERTYPESDL=1 HAVE_JWZGLES=1 USE_OPENGL=1
    echo -e "\nDone."
    exit_message
}

download_data_files() {
    DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME")
    message_magic_air_copy "$VAR_DATA_NAME"
    download_and_extract "$DATA_URL" "$INSTALL_DIR/JediAcademy/base"
}

install() {
    install_script_message
    echo -e "\n\nInstalling OpenJK, please wait..."
    mkdir -p "$INSTALL_DIR" && cd "$_" || exit 1
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    mv "$INSTALL_DIR/JediAcademy/openjk" ~/.local/share/
    generate_icons
    if exists_magic_file; then
        download_data_files
        echo -e "\n\nDone!. You can play typing $INSTALL_DIR/JediAcademy/openjk_sp.arm or opening the Menu > Games > OpenJK.\n"
        runme
    fi

    echo -e "\nDone. Copy the *.pk3 data files inside $INSTALL_DIR/JediAcademy/base and then, you can play typing $INSTALL_DIR/JediAcademy/openjk_sp.arm or opening the Menu > Games > OpenJK"
    open_file_explorer "$INSTALL_DIR/JediAcademy/base"
    exit_message
}

install
