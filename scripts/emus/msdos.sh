#!/bin/bash
#
# Description : MS-DOS Emulator DOSBox-X
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.3.1 (6/Mar/22)
#
# Help        : https://github.com/joncampbell123/dosbox-x/blob/master/BUILD.md
#             : https://krystof.io/dosbox-shaders-comparison-for-modern-dos-retro-gaming/
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/games"
readonly DOSLIB_PATH="$HOME/sc/doslib/tool/linker/linux-host"
readonly PACKAGES=(libsdl2-net-2.0-0)
readonly PACKAGES_DEV=(sudo apt install automake gcc g++ make libncurses-dev nasm libsdl-net1.2-dev libsdl2-net-dev libpcap-dev libslirp-dev fluidsynth libfluidsynth-dev libavdevice58 libavformat-dev libavcodec-dev libavcodec-extra libavcodec-extra58 libswscale-dev libfreetype-dev libxkbfile-dev libxrandr-dev)
readonly BINARY_URL="https://misapuntesde.com/rpi_share/dosbox-X-rpi_0-83.24.tar.gz"
readonly GAME_DATA_URL="https://misapuntesde.com/res/jill-of-the-jungle-the-complete-trilogy.zip"
readonly SOURCE_CODE_URL="https://github.com/joncampbell123/dosbox-x"
readonly SOURCE_CODE_DOSLIB_URL="https://github.com/joncampbell123/doslib"

runme() {
    echo
    if [ ! -f "$INSTALL_DIR/dosbox/dosbox-x" ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run..."
    cd "$INSTALL_DIR/dosbox" && ./dosbox-x
    exit_message
}

remove_files() {
    [[ -d $INSTALL_DIR/dosbox ]] && rm -rf "$INSTALL_DIR/dosbox" ~/.dosbox ~/.local/share/applications/dosbox-x.desktop
}

uninstall() {
    read -p "Do you want to uninstall Dosbox (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e "$INSTALL_DIR/dosbox/dosbox-x" ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -e $INSTALL_DIR/dosbox/dosbox-x ]]; then
    echo -e "DOSBox-X already installed.\n"
    uninstall
fi

make_desktop_entry() {
    if [[ ! -e ~/.local/share/applications/dosbox-x.desktop ]]; then
        cat <<EOF >~/.local/share/applications/dosbox-x.desktop
[Desktop Entry]
Name=DOSBox-X
Exec=${INSTALL_DIR}/dosbox/run.sh
Path=${INSTALL_DIR}/dosbox/
Icon=${INSTALL_DIR}/dosbox/dosbox.png
Type=Application
Comment=Cross-platform DOS emulator
Categories=Game;Emulator;
EOF
    fi
}

compile_doslib_repository() {
    [[ -f $DOSLIB_PATH/lnkdos16 ]] && return 0
    echo -e "Compiling file lnkdos16..."
    mkdir -p "$HOME/sc" && cd "$_" || return
    git clone "$SOURCE_CODE_DOSLIB_URL" doslib && cd "$_"/tool/linker/ || return
    make
}

compile() {
    [[ -e $HOME/sc/dosbox-x ]] && rm -rf "$HOME/sc/dosbox-x"
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    compile_doslib_repository
    mkdir -p "$HOME/sc" && cd "$_" || return
    git clone "$SOURCE_CODE_URL" dosbox-x && cd "$_" || return
    PATH=$PATH:$DOSLIB_PATH ./autogen.sh
    PATH=$PATH:$DOSLIB_PATH ./configure --enable-core-inline --enable-debug=heavy --prefix="$HOME/sc/dosbox-x/bin" --enable-sdl2 --enable-silent-rules --enable-scaler-full-line --disable-dependency-tracking --disable-sdl2test --disable-alsatest --disable-printer --disable-screenshots --disable-avcodec --host=arm-raspberry-linux-gnueabihf || exit 1
    echo -e "\nCompiling... It can takes ~14 minutes on RPi 4."
    make_with_all_cores
    echo -e "\nDone!. Check the code at $HOME/sc/dosbox-x/src"
    exit_message
}

post_install() {
    [[ ! -d $HOME/.dosbox ]] && mkdir -p "$HOME/.dosbox"
    cp "$PIKISS_DIR/./res/dosbox-0.82.26.conf" "$HOME/.dosbox/"
    echo
    read -p "EXTRA!: Do you want to download Jill of The Jungle Trilogy to play with DOSBox-X? [y/N] " response
    if [[ $response =~ [Yy] ]]; then
        echo -e "\nInstalling Jill of the Jungle..."
        mkdir -p "$INSTALL_DIR/dosbox/dos/jill" && cd "$_" || return
        download_and_extract "$GAME_DATA_URL" "$INSTALL_DIR/dosbox/dos/jill"
    fi
    runme
}

install() {
    echo -e "Installing..."
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    make_desktop_entry
    post_install
    echo -e "\nDone!. Put your games inside $INSTALL_DIR/dosbox/dos. To play, go to $INSTALL_DIR/dosbox and type: ./dosbox-x\n"
}

install_script_message
echo "
DOSBox-X MS-DOS Emulator
========================

· Version 0.83.24 (06/Mar/22).
· More Info: $SOURCE_CODE_URL
· Put your games into: $INSTALL_DIR/dosbox/dos
· Many thanks to Jonathan Campbell.
"

install
