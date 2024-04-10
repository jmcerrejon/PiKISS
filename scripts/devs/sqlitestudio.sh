#!/bin/bash
#
# Description : SQLiteStudio
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (10/Apr/24)
# Tested      : Raspberry Pi 5
#
# shellcheck source=../helper.sh
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

INSTALL_DIR="$HOME/apps/sqlitestudio"
VERSION="3.4.4"
BINARY_URL="https://misapuntesde.com/rpi_share/sqlitestudio-$VERSION-aarch64.tar.gz"
GITHUB_URL="https://github.com/pawelsalawa/sqlitestudio/"
APP_LOGO_URL="https://raw.githubusercontent.com/pawelsalawa/sqlitestudio/master/SQLiteStudio3/docs/sqlitestudio_logo.png"
PACKAGES_DEV=(chrpath libqt5core5a libqt5gui5 libqt5widgets5 libqt5script5 libqt5network5 libqt5xml5 libqt5svg5 libqt5printsupport5 libqt5svg5-dev qtdeclarative5-dev qttools5-dev-tools libsqlite3-dev qttools5-dev tcl qtscript5-dev qt5-image-formats-plugins)
DEMO_FILE_URL="https://github.com/alex-hofsteede/zipcode_db/raw/master/zipcodes.sqlite"

runme() {
    if [ ! -f "$INSTALL_DIR/sqlitestudio" ]; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    echo
    read -p "Press [ENTER] to run..."
    cd "$INSTALL_DIR" && ./sqlitestudio
    exit_message
}

uninstall() {
    read -p "Do you want to uninstall SQLiteStudio (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        rm -rf "$INSTALL_DIR" ~/.local/share/applications/sqlitestudio.desktop ~/.config/SalSoft
        if [[ -e $INSTALL_DIR/sqlitestudio ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if [[ -e $INSTALL_DIR/sqlitestudio ]]; then
    echo -e "SQLiteStudio already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nCreating shortcut icon..."
    if [[ ! -e ~/.local/share/applications/sqlitestudio.desktop ]]; then
        download_file "$APP_LOGO_URL" "$INSTALL_DIR"
        cat <<EOF >~/.local/share/applications/sqlitestudio.desktop
[Desktop Entry]
Name=SQLiteStudio
Exec=${INSTALL_DIR}/sqlitestudio
Path=${INSTALL_DIR}/
Icon=${INSTALL_DIR}/sqlitestudio_logo.png
Type=Application
Comment=SQLiteStudio is a free, open source, multi-platform SQLite database manager.
Categories=Development;IDE;
EOF
    fi
}

post_install() {
    echo
    read -p "Would you like to download a demo database to test SQLiteStudio? (y/N) " response
    if [[ $response =~ [Yy] ]]; then
        download_file "$DEMO_FILE_URL" "$INSTALL_DIR"
        echo -e "\n\nDone!. You can find the demo database at $INSTALL_DIR/zipcodes.sqlite"
    fi
}

install() {
    echo -e "\nInstalling, please wait..."
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    generate_icon
    post_install
    echo -e "\nDone!. App at $INSTALL_DIR/sqlitestudio or Go to Menu > Programming > SQLiteStudio"
    runme
}

compile() {
    echo -e "\nDownloading and compiling, be patience..."
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    if [[ ! -d ~/sc/sqlitestudio ]]; then
        mkdir -p ~/sc && cd "$_" || exit 1
        git clone "$GITHUB_URL" sqlitestudio && cd "$_" || exit 1
        mkdir -p output/build
    fi

    # Remove in sc/sqlitestudio/SQLiteStudio3 the cli module
    sed -i '/cli/d' ~/sc/sqlitestudio/SQLiteStudio3/SQLiteStudio3.pro

    cd ~/sc/sqlitestudio/scripts/linux || exit 1
    ./compile.sh

    # Official plugins

    echo "compiling official plugins."
    mkdir Plugins && cd "$_" || exit 1
    qmake ../../../Plugins
    make_with_all_cores

    read -p "\nDone!. Check directory $HOME/sc/sqlitestudio/output/build/sqlitestudio if all goes OK."
    exit_message
    exit 0
}

install_script_message
echo "
SQLiteStudio $VERSION
==================

 · More Info: $GITHUB_URL
 · Install path: $INSTALL_DIR
 · Go to Menu > Programming > SQLiteStudio.
"
read -p "Press [ENTER] to continue..."

install
