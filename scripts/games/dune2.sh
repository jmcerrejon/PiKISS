#!/bin/bash
#
# Description : Dune 2
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.4.0 (17/Mar/25)
# Tested      : Raspberry Pi 5
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }
clear

readonly INSTALL_DIR="$HOME/games"
readonly DATA_DIR="$HOME/.config/dunelegacy"
readonly PACKAGES=(libopusfile0 libsdl2-mixer-2.0-0)
readonly PACKAGES_DEV=(libsdl2-dev libsdl2-mixer-dev libsdl2-ttf-dev libopusfile-dev libjpeg-dev libpng-dev zlib1g-dev)
readonly SOURCE_CODE_URL="git://dunelegacy.git.sourceforge.net/gitroot/dunelegacy/dunelegacy"
readonly DUNELEGACY_WEBSITE="https://dunelegacy.sourceforge.net"
readonly DUNELEGACY_DEB="https://sourceforge.net/projects/dunelegacy/files/dunelegacy/0.96.4/dunelegacy_0.96.4_armhf.deb/download"
readonly BINARY_64_BITS_URL="https://misapuntesde.com/rpi_share/dunelegacy_0.96.4_aarch64.tar.gz"
readonly ICON_URL="https://cdn2.steamgriddb.com/icon/5cfea25821cba9dd9af0bb0581cae19f.png"
readonly VAR_DATA_NAME="DUNE_2"

runme() {
    echo
    read -p "Press [ENTER] to run the game..."
    if [[ -d "$INSTALL_DIR"/dunelegacy ]]; then
        cd "$INSTALL_DIR"/dunelegacy || error_message
        ./dunelegacy
    else
        dunelegacy
    fi
    exit_message
}

uninstall() {
    read -p "Do you want to uninstall Dune Legacy (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        if is_userspace_64_bits; then
            rm -rf "$INSTALL_DIR/dunelegacy" "$DATA_DIR" ~/.local/share/applications/dunelegacy.desktop ~/.local/share/icons/dunelegacy.png
        else
            sudo apt remove -y dunelegacy
        fi
        echo -e "\nSuccessfully uninstalled."
    else
        echo -e "\nUninstallation canceled."
    fi
    exit_message
}

if command -v dunelegacy &>/dev/null || [[ -d "$INSTALL_DIR"/dunelegacy ]]; then
    echo -e "Dune Legacy already installed.\n"
    uninstall
fi

generate_icon() {
    echo -e "\nGenerating icon..."
    mkdir -p ~/.local/share/icons
    wget -q "$ICON_URL" -O ~/.local/share/icons/dunelegacy.png
    if [[ ! -e ~/.local/share/applications/dunelegacy.desktop ]]; then
        cat <<EOF >~/.local/share/applications/dunelegacy.desktop
[Desktop Entry]
Name=Dune Legacy
Exec=${INSTALL_DIR}/dunelegacy/dunelegacy
Icon=${INSTALL_DIR}/dunelegacy/dunelegacy.png
Type=Application
Comment=Dune II - The Battle for Arrakis remake
Categories=Game;StrategyGame;
EOF
    fi
}

download_data_files() {
    if exists_magic_file; then
        echo -e "\nDownloading Dune Data,...\n"
        DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME")
        message_magic_air_copy "DUNE 2"
        download_and_extract "$DATA_URL" "$DATA_DIR"
        return 0
    fi
}

compile_dune_legacy() {
    echo -e "\nCompiling Dune Legacy from source...\n"
    install_packages_if_missing "${PACKAGES_DEV[@]}"

    BUILD_DIR="$HOME/sc"
    mkdir -p "$BUILD_DIR" && cd "$_" || error_message

    echo "Cloning the source code..."
    git clone "$SOURCE_CODE_URL" && cd "$_" || {
        echo "Failed to clone repository"
        return 1
    }

    echo "Compiling Dune Legacy (this will take a while)..."
    export AUTOCONF_VERSION=2.69
    autoreconf -fiv || {
        echo "Failed to run autoreconf"
        return 1
    }
    ./buildlocal.sh || {
        echo "Failed to build Dune Legacy"
        return 1
    }

    if [[ ! -f "./src/dunelegacy" ]]; then
        echo "Compilation failed: Binary not found"
        return 1
    fi

    echo "Compilation and installation completed successfully!"
    return 0
}

install_binaries() {
    echo -e "\nInstalling Dune Legacy, please wait...\n"
    if is_userspace_64_bits; then
        download_and_extract "$BINARY_64_BITS_URL" "$INSTALL_DIR" || {
            echo "Failed to download or extract 64-bit binary"
            return 1
        }
    else
        download_and_install "$DUNELEGACY_DEB" || {
            echo "Failed to download or install DEB package"
            return 1
        }
    fi

    return 0
}

install() {
    install_packages_if_missing "${PACKAGES[@]}" || {
        echo "Failed to install required packages"
        exit_message
    }

    install_binaries || {
        echo "Binary installation failed"
        exit_message
    }
    if is_userspace_64_bits; then
        generate_icon
    fi
    download_data_files

    echo -e "\nDone! Click on Menu > Games > Dune Legacy or type '${INSTALL_DIR}/dunelegacy/dunelegacy' to play."
    runme
}

install_script_message
echo "
Dune Legacy - Dune II remake
============================

 · Visit the project at $DUNELEGACY_WEBSITE
 · You need original game .PAK files to play. Copy them to $DATA_DIR/data
"

read -p "Do you want to continue? (y/N) " response
if [[ $response =~ [Nn] ]]; then
    exit_message
fi

install
