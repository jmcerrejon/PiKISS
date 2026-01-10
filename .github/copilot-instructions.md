---
applyTo: "**/*.sh"
---

# PiKISS Workspace Context

## Project Overview

This workspace contains **PiKISS** (Pi Keeping It Simple, Stupid!) - a collection of Bash scripts with a menu system designed to automate software installation and configuration on Raspberry Pi devices. The project aims to simplify the process of setting up applications, emulators, development tools, and system configurations.

## Required Structure

```bash
#!/bin/bash
# Description : Descriptive name
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (DD/MM/YY)
# Compatible  : Raspberry Pi 4, 5

. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh..." && exit 1; }

# Required variables
readonly INSTALL_DIR="$HOME/apps"
readonly PACKAGES=(package1 package2)
readonly BINARY_URL="$PIKISS_REMOTE_SHARE_DIR_URL/app-name.tar.gz"
```

## Required Variables

-   `readonly INSTALL_DIR` (use $HOME/games or $HOME/apps)
-   `readonly PACKAGES=()`
-   `readonly BINARY_URL` (domain: misapuntesde.com/rpi_share/)

## Standard Functions

-   Include `runme()`, `uninstall()`, `install()`
-   Use `install_packages_if_missing`
-   Call `generate_icon` for GUI applications
-   End with `exit_message`

## User Messages

-   Clear description before installation
-   Show final path and controls/keys
-   Confirm destructive actions with [y/N]

## Instructions for AI

1. **ALWAYS verify helper.sh at start**
2. **USE readonly for all URLs and constants**
3. **INCLUDE informative message with install_script_message**
4. **GENERATE desktop icon if GUI application**
5. **HANDLE both precompiled binaries and compilation**
6. **CHECK architecture with is_userspace_64_bits for specific binaries**
7. **USE dialog for user interaction**
8. **USE functions from helper.sh for common tasks**
9. **FOLLOW the structure and patterns established in existing scripts**

## Key Components

-   **Main script**: [`piKiss.sh`](piKiss.sh) - Entry point with dialog-based menu system
-   **Helper functions**: [`scripts/helper.sh`](scripts/helper.sh) - Common utilities and functions
-   **Script categories**:
    -   `scripts/games/` - Game installations (GTA, VVVVVV, Captain S, etc.)
    -   `scripts/devs/` - Development tools (VSCode, Qt5, Docker, etc.)
    -   `scripts/emus/` - Emulators (PSP, Commodore 64, etc.)
    -   `scripts/config/` - System configurations (Vulkan, networking)
    -   `scripts/server/` - Server applications (Jenkins, Git server)
    -   `scripts/others/` - Miscellaneous tools (Alacritty, Wine, etc.)

## Target Platform

-   Primary: Raspberry Pi 4 and 5
-   OS: Raspberry Pi OS (Bullseye/Bookworm), 64-bit support
-   Also compatible with other ARM-based systems

## Common Patterns

-   Scripts use `dialog` for interactive menus
-   Functions like `install_packages_if_missing`, `download_and_extract`, `make_with_all_cores`
-   Consistent structure: install from binary vs compile from source options
-   Icon generation and desktop entry creation
-   Automatic dependency management

## Practical Examples

### 1. Basic Script Structure

```bash
#!/bin/bash
#
# Description : Example script
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (DD/MM/YY)
#
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh..." && exit 1; }

readonly INSTALL_DIR="$HOME/apps"
readonly PACKAGES=(package1 package2)
readonly BINARY_URL="$PIKISS_REMOTE_SHARE_DIR_URL/app.tar.gz"

install() {
    install_packages_if_missing "${PACKAGES[@]}"
    download_and_extract "$BINARY_URL" "$INSTALL_DIR"
    generate_icon
}

uninstall() {
    read -p "Do you want to uninstall? (y/N) " response
    if [[ $response =~ [Yy] ]]; then
        delete_dir "$INSTALL_DIR/app"
    fi
}

runme() {
    install
    exit_message
}

# Entry point
install_script_message
runme
```

### 2. Handling Different Architectures

```bash
if is_userspace_64_bits; then
    readonly BINARY_URL="$PIKISS_REMOTE_SHARE_DIR_URL/app-arm64.tar.gz"
else
    readonly BINARY_URL="$PIKISS_REMOTE_SHARE_DIR_URL/app-armhf.tar.gz"
fi
```

### 3. Desktop Icon Generation (GUI)

```bash
generate_icon() {
    if [ ! -d "$HOME/.local/share/applications" ]; then
        mkdir -p "$HOME/.local/share/applications"
    fi

    cat << EOF > "$HOME/.local/share/applications/app.desktop"
[Desktop Entry]
Name=App Name
Comment=App Description
Exec=$INSTALL_DIR/app/app
Icon=$INSTALL_DIR/app/icon.png
Terminal=false
Type=Application
Categories=Game;
EOF
}
```

### 4. Build from Source

```bash
compile() {
    install_packages_if_missing "${PACKAGES_DEV[@]}"
    cd "$HOME/source" || exit 1
    git clone "$SOURCE_URL" && cd "$_" || exit 1
    ./configure
    make_with_all_cores
    make_install_compiled_app
    exit_message
}
```

## Author

Jose Cerrejon Gonzalez (ulysess@gmail.com) - Spanish developer focused on Raspberry Pi ecosystem

When answering questions about this codebase, consider the automation focus, Raspberry Pi hardware limitations, and the goal of making complex installations simple for end users.

## Codeguide

When analyzing and assisting with the PiKISS project code, consider the following guidelines and common improvement areas to offer more efficient and contextualized suggestions:

1.  **Consistency in User Interaction:**

    -   Many scripts use `read -p "QUESTION (y/N)? " response` followed by `if [[ $response =~ [Yy] ]]`. Consider refactoring this into a reusable function within `scripts/helper.sh`, for example, `ask_yes_no "QUESTION"`. This would reduce duplication and improve readability. You can see examples of this pattern in `scripts/tweaks/removepkg.sh` and `scripts/info/mangohud.sh`.
    -   Ensure that messages to the user are clear, informative, and consistent across all scripts.

2.  **Centralized Use of `scripts/helper.sh`:**

    -   The `scripts/helper.sh` file is fundamental. Encourage adding common functions to this file to avoid code duplication (e.g., package installation, repository cloning, compilation using all cores like the `make_with_all_cores` function referenced in `scripts/devs/sqlitestudio.sh`).
    -   The method for obtaining `scripts/helper.sh` (seen in scripts like `scripts/games/vvvvvv.sh`: `. scripts/helper.sh || . scripts/helper.sh || wget ...`) is a common pattern. Evaluate if there are more robust or centralized ways to ensure its availability.

3.  **Dependency Management and System Commands:**

    -   Many scripts install packages with `sudo apt install -y ...` (e.g., `scripts/others/jasper.sh`). Encourage using helper functions like `install_packages_if_missing` (from `scripts/others/gl4es.sh`) to first check if packages are already installed.
    -   Be mindful of `sudo` usage. Although necessary for many operations, ensure it is used only when essential and that scripts inform the user appropriately.

4.  **Script Structure and Readability:**

    -   Encourage the use of constants (`readonly` variables) for URLs, directory names, package lists, as seen in `scripts/games/vvvvvv.sh` and `scripts/devs/vscode.sh`.
    -   Promote splitting long scripts into smaller, manageable functions, as observed in `scripts/tweaks/others.sh` and `scripts/devs/vscode.sh` with functions like `install_vscode` or `install_vscodium`.
    -   Remember the use of `shellcheck` (mentioned in `.shellcheckrc` and in the VSCode extension installation in the `install_essential_extensions_pack` function of the `scripts/devs/vscode.sh` script) to maintain Bash code quality.

5.  **Error Handling and Output:**

    -   Encourage the consistent use of functions like `exit_message` (seen in `scripts/info/mangohud.sh` and `scripts/devs/sqlitestudio.sh`) for output and user notification.
    -   Ensure that scripts handle errors appropriately (e.g., `cd "$_" || exit 1` as in `scripts/devs/sqlitestudio.sh`).

6.  **PiKISS Specific Context:**

    -   Remember that the main goal of PiKISS is to simplify software installation and configuration on Raspberry Pi, as indicated in `README.md`. Suggestions should align with this objective.

7.  **Remote Resources Management:**

    -   Consistent use of `PIKISS_REMOTE_SHARE_DIR_URL` for binary files
    -   Use `download_and_extract` to handle remote archives
    -   Validate URLs and downloads with `is_URL_down` and `validate_url`

8.  **Common Utility Functions:**

    -   `get_distro_name` and `get_codename` for system info
    -   `directory_exist` and `delete_dir` for directory management
    -   `is_integer` for input validation
    -   `check_update` for package index updates
    -   `pip_install` and `install_packages_if_missing` for package management

9.  **Logging and Messaging:**

    -   Use `log_message` for structured logs
    -   `error_exit` for controlled exits
    -   `install_script_message` for install start
    -   `exit_message` for completion

10. **System Integration:**

    -   `check_internet_available` to validate connectivity
    -   `restart_panel` to restart UI components
    -   `open_file_explorer` to integrate with file managers
    -   `generate_icon` to integrate with desktop entries

By applying these guidelines, more precise and valuable assistance can be offered for the development and maintenance of the PiKISS project.

Remember all comments, naming conventions, and structure when generating or modifying code must be in english.
