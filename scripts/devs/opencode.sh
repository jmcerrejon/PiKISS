#!/bin/bash
#
# Description : OpenCode - AI coding agent for the terminal
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (18/Apr/26)
# Tested      : Raspberry Pi 5
#
# shellcheck source=../helper.sh
. ../helper.sh || . ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly SOURCE_CODE_URL="https://github.com/anomalyco/opencode"

uninstall() {
    read -p "Do you want to uninstall OpenCode (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        opencode uninstall --force
        rm -rf "$HOME/.opencode"
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

if which opencode >/dev/null; then
    echo -e "OpenCode already installed.\n"
    uninstall
    exit 1
fi

install() {
    echo -e "\nInstalling OpenCode via official install script..."
    curl -fsSL https://opencode.ai/install | bash
    echo -e "\nDone!. Open a new terminal and type 'opencode' into your awesome code project."
    exit_message
}

install_script_message
echo "
OpenCode
========

 · An open-source AI coding agent built for the terminal.
 · Supports 75+ LLM providers including GPT, Gemini, Claude (blocked), and local models via Ollama.
 · More info: $SOURCE_CODE_URL
"
read -p "Press [ENTER] to continue..."

install