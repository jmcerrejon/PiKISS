#!/bin/bash
#
# Description     : LITert-LM
# Author          : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version         : 1.0.0 (07/Jun/26)
# Compatible      : Raspberry Pi 4, 5
#
# shellcheck source=../helper.sh
. ../helper.sh || . ./scripts/helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh..." && exit 1; }

readonly INSTALL_DIR="$HOME/.litert-lm"

runme() {
    if ! which litert-lm >/dev/null; then
        echo -e "\nFile does not exist.\n   Something is wrong.\n   Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run LITert-LM..."
    litert-lm
    exit_message
}

uninstall() {
    read -p "Do you want to uninstall Litert-LM and installed models (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        uv tool uninstall litert-lm
        rm -rf "$INSTALL_DIR"
        if which litert-lm >/dev/null; then
            echo -e "Could not fully uninstall. Try manually.\n"
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
    fi
    exit_message
}

if which litert-lm >/dev/null; then
    echo -e "Litert-LM already installed.\n"
    uninstall
    exit 1
fi

install() {
    echo -e "\nInstalling uv tool (litert-lm)..."
    uv tool install litert-lm --force > /dev/null 2>&1 || { echo "Failed to install litert-lm"; error_exit; }
    litert-lm import --from-huggingface-repo litert-community/gemma-4-E2B-it-litert-lm gemma-4-E2B-it.litertlm gemma4-e2b
    echo -e "\nDone. Type 'litert-lm help' or 'litert-lm run gemma4-e2b' and tell him what can do in your terminal. Check Documentation at: https://developers.google.com/edge/litert-lm/cli/usage"
    exit_message
}

install_script_message
echo "
LITert-LM
=========

· An open-source AI language model server.
· Model: Gemma-4 E2B IT from litert-community on HuggingFace.
"

read -p "Press [ENTER] to continue..."
install
