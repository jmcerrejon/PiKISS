#!/bin/bash
#
# Description : Install Lynis. Lynis is a security auditing tool for Unix and Linux based systems.
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 2.1.0 (25/Apr/26)
# Tested      : Raspberry Pi 5
#
# shellcheck disable=SC1094
# shellcheck disable=SC1091
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly DOWNLOAD_URL="https://downloads.cisofy.com/lynis/lynis-3.1.6.tar.gz"

check_system() {
    if [[ $(validate_url $DOWNLOAD_URL) != "true" ]] ; then
        read -p "Sorry, the file is not available here: $DOWNLOAD_URL. Visit the website at https://cisofy.com/download/lynis/ to download it manually."
        exit_message
    fi

    download_and_extract "$DOWNLOAD_URL" "/tmp"
    chown -R 0:0 lynis
    cd lynis
    echo -e "\nRunning Lynis audit. This may take a while..."
    ./lynis audit system -Q > "$HOME/lynis_report.txt"
    rm -rf /tmp/lynis "$HOME/lynis.log" "$HOME/lynis_report.dat"

    echo -e "\nDone! The report has been saved to $HOME/lynis_report.txt"
    exit_message
}

install_script_message
echo "
Lynis
=====

· Lynis is a security auditing tool for UNIX derivatives like Linux, macOS, BSD, Solaris, AIX, and others. It performs an in-depth security scan.
· Assists with compliance testing (HIPAA/ISO27001/PCI DSS) and system hardening. Agentless, and installation optional.
"

read -p "Do you want to scan your system now (no installation required)? (y/N) " response
if [[ $response =~ [Nn] ]]; then
    exit_message
fi

check_system
