#!/bin/bash
#
# Description : Gemini CLI
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (25/Jul/25)
# Tested      : Raspberry Pi 5
#
# shellcheck source=../helper.sh
. ../helper.sh || . ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly SOURCE_CODE_URL="https://github.com/google-gemini/gemini-cli"

runme() {
    if ! which gemini >/dev/null; then
        echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
        exit_message
    fi
    read -p "Press [ENTER] to run Gemini CLI..."
    gemini
    exit_message
}

uninstall() {
    read -p "Do you want to uninstall Gemini CLI (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo npm uninstall -g @google/gemini-cli
        if which gemini >/dev/null; then
            echo -e "I hate when this happens. Could not uninstall. Try to do it manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if which gemini >/dev/null; then
    echo -e "Gemini CLI already installed.\n"
    uninstall
    exit 1
fi

install() {
    echo -e "\nInstalling Node.js v20 (if not present)..."
    install_node 20
    echo -e "\nInstalling Gemini CLI globally via npm..."
    sudo npm install -g @google/gemini-cli
    echo -e "\nDone!. Type 'gemini' in your terminal."
    echo -e "On the first run, you will be prompted to authenticate with your Google account."
    runme
}

install_script_message
echo "
Gemini CLI
==========

 · An open-source AI agent that brings the power of Gemini directly into your terminal.
 · It will install Node.js v20 if not present.
 · More info: $SOURCE_CODE_URL
"
read -p "Press [ENTER] to continue..."

install
