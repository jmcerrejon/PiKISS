#!/bin/bash
#
# Description : Amiberry Amiga emulator
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.5.6 (12/Mar/22)
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/games"
AMIBERRY_VERSION="v4.1.6"
ARCHITECTURE=$(getconf LONG_BIT)
PACKAGES=(libsdl2-image-2.0-0 libsdl2-ttf-2.0-0)
PACKAGES_DEV=(libsdl2-dev libguichan-dev libsdl2-ttf-dev libsdl-gfx1.2-dev libxml2-dev libflac-dev libmpg123-dev)
RPI_MODEL=$(get_raspberry_pi_model_number)
FILE_NAME=
BINARY_URL="https://github.com/midwan/amiberry/releases/download/${AMIBERRY_VERSION}/amiberry-${AMIBERRY_VERSION}-rpi${RPI_MODEL}-sdl2-${ARCHITECTURE}bit-rpios.zip"
GITHUB_PATH="https://github.com/midwan/amiberry.git"
KICK_FILE="https://misapuntesde.com/res/Amiga_roms.zip"
GAME="https://www.emuparadise.me/GameBase%20Amiga/Games/T/Turrican.zip"
ICON_URL="https://raw.githubusercontent.com/midwan/amiberry/master/data/amiberry.png"
INPUT=/tmp/amigamenu.$$

runme() {
    if [[ ! -f $INSTALL_DIR/amiberry/amiberry.sh ]]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run..."
    cd "$INSTALL_DIR/amiberry" && ./amiberry.sh
    exit_message
}

remove_files() {
    rm -rf "$INSTALL_DIR/amiberry" ~/.local/share/applications/amiberry.desktop
}

uninstall() {
    read -p "Do you want to uninstall Amiberry (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e $INSTALL_DIR/amiberry ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -e $INSTALL_DIR/amiberry ]]; then
    echo -e "Amiberry already installed.\n"
    uninstall
fi

post_install() {
    echo -e "\nPost install process. Just a moment..."
    cat <<EOF >"$INSTALL_DIR"/amiberry/amiberry.sh
#!/bin/bash
cd ${HOME}/games/amiberry && ./amiberry
EOF
    chmod +x "$INSTALL_DIR/amiberry/amiberry.sh"
    downloadROM
    downloadKICK
    make_desktop_entry
    end_message
}

downloadKICK() {
    echo -e "\nCopying Rickstarts ROMs...\n"
    download_and_extract "$KICK_FILE" "$INSTALL_DIR/amiberry/kickstarts"
    mv "$INSTALL_DIR"/amiberry/kickstarts/kick13.rom "$INSTALL_DIR"/amiberry/kickstarts/kick.rom
}

downloadROM() {
    download_and_extract "$GAME" "$INSTALL_DIR/amiberry"
}

make_desktop_entry() {
    wget -q "$ICON_URL" -O "$INSTALL_DIR"/amiberry/amiberry.png
    if [[ ! -e ~/.local/share/applications/amiberry.desktop ]]; then
        cat <<EOF >~/.local/share/applications/amiberry.desktop
[Desktop Entry]
Name=Amiberry
Exec=${INSTALL_DIR}/amiberry/amiberry.sh
Path=${INSTALL_DIR}/amiberry/
Icon=${INSTALL_DIR}/amiberry/amiberry.png
Type=Application
Comment=Amiga emulator port.
Categories=Game;
EOF
    fi
}

end_message() {
    echo -e "\n\nDone!. You can play typing $INSTALL_DIR/amiberry/amiberry.sh or opening the Menu > Games > Amiberry.\n"
    runme
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    mkdir -p "$HOME"/sc && cd "$_" || exit 1
    echo "Cloning and compiling repo..."
    git clone "$GITHUB_PATH" amiberry && cd "$_" || exit 1
    make_with_all_cores
    downloadKICK
    echo -e "\nDone!. Compiled path: $HOME/sc/amiberry"
    exit_message
}

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    mv "amiberry-rpi4-sdl2-${ARCHITECTURE}bit" amiberry
    # chmod +x "$INSTALL_DIR"/amiberry/amiberry
    post_install
}

install_script_message
echo "
Amiberry for Raspberry Pi
=========================

 · Version ${AMIBERRY_VERSION}
 · More Info: https://github.com/midwan/amiberry
 · Kickstar ROMs & Turrican included.
 · Install path: $INSTALL_DIR/amiberry
 · TIP: F12 = Menu | Change your input device in the menu | Quickstart and select Disk image.
"
read -p "Press [ENTER] to continue..."

install
