#!/bin/bash
#
# Description : Metasploit Framework
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (13/Jan/24)
# Tested on   : Raspberry Pi 5
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/sc"
readonly METASPLOIT_INSTALL_URL="https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb"
readonly DOCUMENTATION_URL="https://docs.metasploit.com/docs/using-metasploit/basics/"
readonly EXEC_FILE_PATH="/usr/bin/msfconsole"

uninstall() {
    read -p "Do you want to uninstall (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        sudo apt remove -y metasploit-framework
        if [[ -e $EXEC_FILE_PATH ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    exit_message
}

install_metasploit() {
    echo -e "\nInstalling MetaSploit (latest)...\n\n"
    curl  "$METASPLOIT_INSTALL_URL" > msfinstall
    chmod 755 msfinstall
    ./msfinstall
    rm ./msfinstall
}

if [[ -e $EXEC_FILE_PATH ]]; then
    echo -e "\nMetaSploit already installed.\n"
    uninstall
fi

install() {
    install_metasploit
    read "Done!. To run, type: msfconsole."
    exit_message
}

install_script_message
echo "
Metasploit Framework
====================

· The world’s most used penetration testing framework.
· Metasploit is based around the concept of modules. The most commonly used module types are: Auxiliary, Exploit, Payloads & Post.
· + Information: $DOCUMENTATION_URL
"

read -p "Are you sure you want to install? (y/N) " response
if [[ $response =~ [Yy] ]]; then
    install
fi