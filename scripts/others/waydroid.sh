#!/bin/bash
#
# Description : Waydroid installation script
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot_com)
# Version     : 1.0.0 (08/Jun/25)
# Tested      : Raspberry Pi 5
#
# Help        : https://pimylifeup.com/raspberry-pi-waydroid
#

# Enable strict error handling
set -euo pipefail

# shellcheck disable=SC1094
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

readonly INSTALL_DIR="$HOME/waydroid"
readonly PACKAGES=(git lxc lxc-templates python3 python3-pip python3-setuptools python3-wheel)
readonly WAYDROID_REPO_URL="https://github.com/waydroid/waydroid.git"

clone_repo() {
    log_message "INFO" "Cloning Waydroid repository..."
    cd "$HOME" || error_exit "Failed to navigate to home directory"

    if [[ -d "$INSTALL_DIR" ]]; then
        log_message "INFO" "Removing existing Waydroid directory..."
        rm -rf "$INSTALL_DIR"
    fi

    git clone "$WAYDROID_REPO_URL" "$INSTALL_DIR" || error_exit "Failed to clone Waydroid repository"
    log_message "INFO" "Repository cloned successfully"
}

install_waydroid() {
    install_packages_if_missing "${PACKAGES[@]}"
    clone_repo
    log_message "INFO" "Installing Waydroid..."
    cd "$INSTALL_DIR" || error_exit "Failed to enter Waydroid directory"

    sudo ./install.sh || error_exit "Failed to install Waydroid"

    log_message "INFO" "Waydroid installation completed successfully"

    if command -v waydroid &>/dev/null; then
        log_message "INFO" "Waydroid is installed successfully."
        waydroid version
    else
        log_message "ERROR" "Waydroid installation failed. Please check the logs."
    fi
}

install_script_message
echo "
Waydroid Installation
=====================

· Waydroid is a container-based approach to boot a full Android system on a regular GNU/Linux system.
· This script installs Waydroid on your OS.
"

read -p "Continue? (Y/n) " response
if [[ $response =~ [Nn] ]]; then
    exit_message
fi

install_waydroid
