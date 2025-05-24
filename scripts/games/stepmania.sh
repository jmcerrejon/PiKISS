#!/bin/bash
#
# Description : StepMania
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.3 (07/Aug/23)
# Compatible  : Raspberry Pi 4
# Repository  : https://github.com/stepmania/stepmania
# Help        : https://github.com/SpottyMatt/raspbian-stepmania-deb
#             : https://zenius-i-vanisher.com/v5.2/viewsimfile.php?simfileid=41438
#             : https://zenius-i-vanisher.com/v5.2/viewsimfile.php?simfileid=41430
#
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly PACKAGES=(libvorbisidec1 libopenal1 libsdl2-mixer-2.0-0 libpng16-16 libglu1-mesa p7zip-full pulseaudio)
readonly PACKAGES_DEV=(build-essential cmake mesa-common-dev libglu1-mesa-dev libglew1.5-dev libxtst-dev libxrandr-dev libpng-dev libjpeg-dev zlib1g-dev libbz2-dev libogg-dev libvorbis-dev libc6-dev yasm libasound-dev libpulse-dev binutils-dev libgtk-3-dev libmad0-dev libudev-dev libva-dev nasm pulseaudio)
readonly BINARY_URL="https://archive.org/download/stepmania_5.1-dev-rpi.7z/stepmania_5.1-dev-rpi.7z"
readonly SOURCE_CODE_URL="https://github.com/stepmania/stepmania"

runme() {
    if [ ! -f "$INSTALL_DIR"/stepmania/stepmania ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run..."
    cd "$INSTALL_DIR"/stepmania && ./stepmania
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR"/stepmania ~/.local/share/applications/stepmania.desktop
}

uninstall() {
    read -p "Do you want to uninstall StepMania (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR"/stepmania ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -d "$INSTALL_DIR"/stepmania ]]; then
    echo -e "StepMania already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    if [[ ! -e ~/.local/share/applications/stepmania.desktop ]]; then
        cat <<EOF >~/.local/share/applications/stepmania.desktop
[Desktop Entry]
Name=StepMania
Type=Application
Comment=StepMania is a free dance and rhythm game
Exec=${INSTALL_DIR}/stepmania/stepmania
Icon=${INSTALL_DIR}/stepmania/icons/hicolor/128x128/apps/stepmania-ssc.png
Path=${INSTALL_DIR}/stepmania/
Terminal=false
Categories=Game;
EOF
    fi
}

end_message() {
    echo -e "\n\nDone!. You can play typing $INSTALL_DIR/stepmania/stepmania or opening the Menu > Games > StepMania."
    runme
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME/sc" && cd "$_" || return
    git clone --depth=1 https://github.com/stepmania/stepmania
    git submodule update --init
    mkdir build && cd "$_" || return
    cmake -G 'Unix Makefiles' -DCMAKE_BUILD_TYPE=RelWithDebInfo -DWITH_CRASH_HANDLER=OFF .. && cmake ..
    make_with_all_cores
    make_install_compiled_app
    echo -e "\nDone!. Check the code at $HOME/sc/stepmania."
    exit_message
}

download_binaries() {
    echo -e "\nInstalling binary files..."
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
}

post_install() {
    systemctl --user restart pulseaudio.service
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    download_binaries
    generate_icon
    post_install
    end_message
}

install_script_message
echo "
StepMania (AKA Dance Dance Revolution) for Raspberry Pi
=======================================================

 · Optimized for Raspberry Pi 4.
 · More info: https://github.com/SpottyMatt/raspbian-stepmania-arcade
 · Tons of songs at https://search.stepmaniaonline.net/ | https://zenius-i-vanisher.com/v5.2/index.php
 · It allows to work laterality, spatial perception and rhythm. Tell your parents when see you playing this game.
 · It uses Pulseaudio. REBOOT if you don't hear anything. I'll try to compile with another sound driver in a future.
 · NOTE: Maybe broke something on your side related with sound on others apps/games. If so: sudo apt uninstall -y pulseaudio
"
read -p "Press [Enter] to continue..."

install
