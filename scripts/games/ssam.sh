#!/bin/bash
#
# Description : Serious Sam 1 & 2
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 2.0.2 (07/Aug/23)
# Compatible  : Raspberry Pi 4 (tested)
#
# TODO        :  32 bits support, Mods support.
#

. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly PACKAGES_DEV=(git bison flex cmake make gcc libc6-dev libsdl2-dev libogg-dev libvorbis-dev zlib1g-dev)
VERSION_NUMBER="1.10.4-1"
ALPHA_VERSION_NUMBER="1.5.1-1"
PKG_SERIOUSSAM_CLASSIC_32_URL="https://github.com/tx00100xt/serioussam-packages/raw/main/RasberryPiOS/RPi4B/armhf/serioussamclassic-${VERSION_NUMBER}_rpi4b_armhf.deb"
PKG_SERIOUSSAM_CLASSIC_VK_32_URL="https://github.com/tx00100xt/serioussam-packages/raw/main/RasberryPiOS/RPi4B/armhf/serioussamclassic-vk-${VERSION_NUMBER}_rpi4b_armhf.deb"
PKG_SERIOUSSAM_CLASSIC_XPLUS_32_URL="https://github.com/tx00100xt/serioussam-packages/raw/main/RasberryPiOS/RPi4B/armhf/serioussamclassic-xplus-${VERSION_NUMBER}_rpi4b_armhf.deb"
PKG_SERIOUSSAM_CLASSIC_ALPHA_32_URL="https://github.com/tx00100xt/serioussam-packages/raw/main/RasberryPiOS/RPi4B/armhf/serioussamclassic-alpha-${ALPHA_VERSION_NUMBER}_rpi4b_armhf.deb"
PKG_SERIOUSSAM_CLASSIC_64_URL="https://github.com/tx00100xt/serioussam-packages/raw/main/RasberryPiOS/RPi4B/arm64/serioussamclassic-${VERSION_NUMBER}_rpi4b_arm64.deb"
PKG_SERIOUSSAM_CLASSIC_VK_64_URL="https://github.com/tx00100xt/serioussam-packages/raw/main/RasberryPiOS/RPi4B/arm64/serioussamclassic-vk-${VERSION_NUMBER}_rpi4b_arm64.deb"
PKG_SERIOUSSAM_CLASSIC_XPLUS_64_URL="https://github.com/tx00100xt/serioussam-packages/raw/main/RasberryPiOS/RPi4B/arm64/serioussamclassic-xplus-${VERSION_NUMBER}_rpi4b_arm64.deb"
PKG_SERIOUSSAM_CLASSIC_ALPHA_64_URL="https://github.com/tx00100xt/serioussam-packages/raw/main/RasberryPiOS/RPi4B/arm64/serioussamclassic-alpha-${ALPHA_VERSION_NUMBER}_rpi4b_arm64.deb"
readonly SOURCE_CODE_URL="https://github.com/tx00100xt/SeriousSamClassic"
readonly VAR_DATA_NAME_1="SSAM_TFE"
readonly VAR_DATA_NAME_2="SSAM_TSE"
INPUT=/tmp/ssam.$$

remove_files() {
    sudo dpkg --purge serioussamclassic serioussamclassic-xplus serioussamclassic-vk serioussamclassic-alpha
    rm -rf ~/.local/share/applications/Serious-Engine
}

uninstall() {
    read -p "Do you want to uninstall it (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        remove_files
        if [[ -e /usr/lib/aarch64-linux-gnu/serioussam ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
}

if [[ -d /usr/lib/aarch64-linux-gnu/serioussam ]]; then
    echo -e "\nSerious Sam engine already installed.\n"
    uninstall
fi

install_full_tfe() {
    local SERIOUSSAM_DIR="$HOME/.local/share/applications/Serious-Engine/serioussam"
    local DATA_URL
    DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME_1")

    read -p "Do you want to install your Serious Sam The First Encounter game data files to $SERIOUSSAM_DIR? (y/N) " response
    if [[ $response =~ [Yy] ]]; then
        message_magic_air_copy "$VAR_DATA_NAME_1"
        download_and_extract "$DATA_URL" "$SERIOUSSAM_DIR"
    fi
}

install_full_tse() {
    local SERIOUSSAM_DIR="$HOME/.local/share/applications/Serious-Engine/serioussamse"
    local DATA_URL
    DATA_URL=$(extract_path_from_file "$VAR_DATA_NAME_2")

    read -p "Do you want to install your Serious Sam The Second Encounter game data files to $SERIOUSSAM_DIR? (y/N) " response
    if [[ $response =~ [Yy] ]]; then
        message_magic_air_copy "$VAR_DATA_NAME_2"
        download_and_extract "$DATA_URL" "$SERIOUSSAM_DIR"
    fi
}

compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    echo -e "\nCompiling Serious Sam..."

    [[ ! -d $HOME/sc ]] && mkdir -p "$HOME/sc"
    cd "$HOME/sc" || exit 1

    git clone "$SOURCE_CODE_URL" && cd Serious-Engine/Sources || exit 1
    time ./build-linux64.sh
    mv cmake-build build-ssam-tse
    # time ./build-linux64.sh -DTFE=TRUE

    if [[ ! -f Sources/cmake-build/ssam ]]; then
        echo -e "\nSomething is wrong.\n· Try to compile it again."
        exit_message
    fi

    echo -e "\nDone!. Check Sources/cmake-build/ssam"
    exit_message
}

install_alpha_data() {
    local SERIOUSSAM_MOD_DIR="$HOME/.local/share/applications/Serious-Engine/serioussam/Mods"

    echo -e "\nInstalling Serious Sam Alpha data files...\n"
    [[ ! -d $SERIOUSSAM_MOD_DIR ]] && mkdir -p "$SERIOUSSAM_MOD_DIR"
    cd "$SERIOUSSAM_DIR" || exit 1

    for var in a b c d; do wget https://github.com/tx00100xt/serioussam-mods/raw/main/SamTFE-SSA/SeriousSamAlphaRemake_v1.5.tar.xz.parta$var; done
    cat SeriousSamAlphaRemake_v1.5.tar.xz.part* >SeriousSamAlphaRemake_v1.5.tar.xz

    echo -e "Uncompressing file...\n"
    tar -xJpf SeriousSamAlphaRemake_v1.5.tar.xz

    rm "$SERIOUSSAM_MOD_DIR/SSA/Bin/libEntities.so" "$SERIOUSSAM_MOD_DIRSSA/Bin/libGame.so"
    rm SeriousSamAlphaRemake_v1.5.tar.xz.part*
}

install_xplus_data() {
    local XPLUS_URL="https://e1.pcloud.link/publink/show?code=XZ02gRZ4nhrRGPSfV4aEL4IF8GYySafWVJX"
    local SERIOUSSAM_DIR="$HOME/.local/share/applications/Serious-Engine/serioussam"

    echo -e "\nInstalling Serious Sam Alpha data files...\n"
    cd "$SERIOUSSAM_DIR" || exit 1
    download "$XPLUS_URL" "$SERIOUSSAM_DIR"
    echo -e "Uncompressing file...\n"
    tar -xJpf SamTFE-XPLUS.tar.xz && rm SamTFE-XPLUS.tar.xz
    rm SamTFE-XPLUS.tar.xz.part*
}

menu() {
    while true; do
        dialog --clear \
            --title "[ Serious Sam ]" \
            --menu "Choose the version:" 11 68 3 \
            Vulkan "Serious Sam Vulkan Edition" \
            XPlus "Serious Sam with visual enhancements" \
            Alpha "Serious Sam lost levels" \
            Exit "Return to main menu" 2>"${INPUT}"

        menuitem=$(<"${INPUT}")

        case $menuitem in
        Vulkan) clear && download_and_install $PKG_SERIOUSSAM_CLASSIC_VK_64_URL && return 0 ;;
        XPlus) clear && download_and_install $PKG_SERIOUSSAM_CLASSIC_XPLUS_64_URL && install_xplus_data && return 0 ;;
        Alpha) clear && download_and_install $PKG_SERIOUSSAM_CLASSIC_ALPHA_64_URL && install_alpha_data && return 0 ;;
        Exit) exit 0 ;;
        esac
    done
}

install() {
    download_and_install $PKG_SERIOUSSAM_CLASSIC_64_URL
    # menu
    if exists_magic_file; then
        echo
        install_full_tfe
        install_full_tse
        exit_message
    fi

    echo -e "\nDone!. Now follow the instructions to copy game data files at https://github.com/tx00100xt/serioussam-packages"
    exit_message
}

install_script_message
echo "
Install Serious Sam 1 & 2
=========================

 · Version $VERSION_NUMBER.
 · Based on the great port by tx00100xt optimized for Raspberry Pi 4.
 · I want to thanks Pi Labs, meveric, Jojo-A, ptitSeb & tx00100xt.
 · REMEMBER YOU NEED A LEGAL COPY OF THE GAME.
"

read -p "Continue? (Y/n) " response
if [[ $response =~ [Nn] ]]; then
    exit_message
fi

install
