#!/bin/bash
#
# Description : OpenXcom with the help of user chills340
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.1.7 (21/Feb/21)
# Compatible  : Raspberry Pi 4 (tested)
#
# Help		  : https://www.ufopaedia.org/index.php/Compiling_with_CMake_(OpenXcom)
#
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libsdl-gfx1.2-5 libglu1-mesa libyaml-cpp0.6)
readonly PACKAGES_DEV=(build-essential libboost-dev libsdl1.2-dev libsdl-mixer1.2-dev libsdl-image1.2-dev libsdl-gfx1.2-dev libyaml-cpp-dev xmlto)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/openxcom_rpi.tar.gz"
readonly SOURCE_CODE_URL="https://github.com/SupSuper/OpenXcom.git"
readonly VAR_DATA_NAME="UFO_ENEMY_UNKNOWN"
INPUT=/tmp/openxcom.$$

runme() {
    echo
    if [[ ! -f $INSTALL_DIR/openxcom/openxcom ]]; then
        echo -e "File does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run the game..."
    cd "$INSTALL_DIR/openxcom" && ./openxcom
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR/openxcom" ~/.local/share/applications/openxcom.desktop ~/.config/openxcom
}

uninstall() {
    read -p "Do you want to uninstall OpenXcom (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/openxcom ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d $INSTALL_DIR/openxcom ]]; then
    echo -e "openxcom already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/openxcom.desktop ]]; then
        cat <<EOF >~/.local/share/applications/openxcom.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=OpenXcom
Comment=Open-source clone of UFO: Enemy Unknown
Exec=${INSTALL_DIR}/openxcom/openxcom
Icon=${INSTALL_DIR}/openxcom/openxcom.svg
Path=${INSTALL_DIR}/openxcom/
Terminal=false
Categories=Game;StrategyGame;
EOF
    fi
}

download_data_files() {
    local DATA_URL
    DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME")
    message_magic_air_copy "$DATA_URL"
    download_and_extract "$DATA_URL" "$INSTALL_DIR/openxcom"
    if [[ -e "$INSTALL_DIR/openxcom/X-Com - UFO Enemy Unknown/" ]]; then
        cd "$INSTALL_DIR/openxcom/X-Com - UFO Enemy Unknown/" || exit 1
        mv ufo UFO && mv -f UFO "$INSTALL_DIR/openxcom" && cd "$_" || exit 1
    fi
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || exit 1
    git clone "$SOURCE_CODE_URL" openxcom && cd "$_" || exit 1
    mkdir build && cd "$_" || exit 1
    cmake -DCMAKE_BUILD_TYPE=Release ..
    make_with_all_cores
    read -p "Do you want to install globally the game (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo make install
    fi
    echo -e "\nDone!. Check the code at $HOME/sc/openxcom."
    exit_message
}

end_message() {
    echo -e "\nDone!. You can play typing $INSTALL_DIR/openxcom/openxcom or opening the Menu > Games > OpenXcom."
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    generate_icon
    if ! exists_magic_file; then
        echo -e "\nCopy the data files inside $INSTALL_DIR/openxcom/UFO."
        end_message
        exit_message
    fi

    download_data_files
    end_message
    runme
}

install_script_message
echo "
OpenXCom on Raspberry Pi
========================

 · Based on engine at ${SOURCE_CODE_URL}
 · The Game data directory must to be in UPPERCASE, so copy it to the destination path $INSTALL_DIR/openxcom/UFO
 · REMEMBER YOU NEED A LEGAL COPY OF THE GAME and copy game directory inside $INSTALL_DIR/openxcom
 · To play, when installed use Menu > Games > OpenXcom or $INSTALL_DIR/openxcom/openxcom
"
read -p "Press [ENTER] to continue..."

install
