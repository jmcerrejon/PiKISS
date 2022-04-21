#!/bin/bash
#
# Description : Helpers functions
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
#
readonly PIKISS_DIR=$PWD
readonly PIKISS_MAGIC_AIR_COPY_PATH=$PIKISS_DIR/res/magic-air-copy-pikiss.txt

# Usage: "${INFO}INFO${RESET}: This is an ${BOLD}info${RESET} message"
BOLD=$(tput bold)
UNDERLINE=$(tput smul)
ITALIC=$(tput sitm)
INFO=$(tput setaf 2)
ERROR=$(tput setaf 160)
WARN=$(tput setaf 214)
RESET=$(tput sgr0)
export BOLD
export UNDERLINE
export ITALIC
export INFO
export ERROR
export WARN
export RESET

#
# Fix libGLESv2.so on Raspbian Stretch
#

fix_libGLES() {
    if [ ! -f /usr/lib/libEGL.so ]; then
        sudo ln -s /usr/lib/arm-linux-gnueabihf/libEGL.so.1.1.0 /usr/lib/libEGL.so
    fi

    if [ ! -f /usr/lib/libGLESv2.so ]; then
        sudo ln -s /usr/lib/arm-linux-gnueabihf/libGLESv2.so.2.1.0 /usr/lib/libGLESv2.so
    fi

    if [ ! -f /usr/lib/libunistring.so.0 ]; then
        sudo ln -s /usr/lib/arm-linux-gnueabihf/libunistring.so.2.1.0 /usr/lib/libunistring.so.0
    fi

    if [ ! -f /usr/lib/arm-linux-gnueabihf/libunistring.so.2 ]; then
        sudo ln -s /usr/lib/arm-linux-gnueabihf/libunistring.so.2 /usr/lib/arm-linux-gnueabihf/libunistring.so.0
    fi
}

box_check_if_latest_version_is_installed() {
    local BOX86_FINAL_PATH
    local BOX86_VERSION
    local GIT_VERSION

    # If Box86 is not installed, skip the process
    command -v box86 >/dev/null 2>&1 || return 0

    BOX86_FINAL_PATH=$(whereis box86 | awk '{print $2}')
    BOX86_VERSION=$("$BOX86_FINAL_PATH" -v | awk '{print $5}')
    GIT_VERSION=$(cd "$HOME/box86" && git rev-parse HEAD | cut -c 1-8)

    if [[ $BOX86_VERSION = "$GIT_VERSION" ]]; then
        true
    else
        false
    fi
}

compile_box86_or_64() {
    local PI_VERSION_NUMBER
    local BOX_VERSION
    local SOURCE_PATH

    if is_userspace_64_bits; then
        BOX_VERSION="box64"
    else
        BOX_VERSION="box86"
    fi

    INSTALL_DIRECTORY="$HOME/$BOX_VERSION"
    PI_VERSION_NUMBER=$(get_raspberry_pi_model_number)
    SOURCE_PATH="https://github.com/ptitSeb/$BOX_VERSION"

    install_packages_if_missing cmake

    if [[ ! -d "$INSTALL_DIRECTORY" ]]; then
        echo
        git clone "$SOURCE_PATH" "$INSTALL_DIRECTORY" && cd "$_" || exit 1
    else
        echo -e "\nUpdating the repo if proceed,...\n"
        cd "$INSTALL_DIRECTORY" && git pull
        [[ -d "$INSTALL_DIRECTORY"/build ]] && rm -rf "$INSTALL_DIRECTORY"/build
    fi

    if [[ -f /usr/local/bin/$BOX_VERSION ]]; then
        if box_check_if_latest_version_is_installed; then
            echo -e "\nYour $BOX_VERSION is already updated. Skipping...\n"
            return 0
        fi
    fi

    mkdir -p build && cd "$_" || exit 1
    echo -e "\nCompiling, please wait...\n"
    cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
    make_with_all_cores
    make_install_compiled_app
    echo -e "\n${BOX_VERSION} successfully installed.\n"
}

install_box86_or_64() {
    local BINARY_BOX_URL
    local BOX_VERSION

    if is_userspace_64_bits; then
        BOX_VERSION="box64"
    else
        BOX_VERSION="box86"
    fi

    BINARY_BOX_URL="https://misapuntesde.com/rpi_share/pilabs/${BOX_VERSION}.tar.gz"

    if [[ -f /usr/local/bin/${BOX_VERSION} ]]; then
        echo
        read -p "${BOX_VERSION} already installed. Do you want to update it (Y/n)? " response
        if [[ $response =~ [Nn] ]]; then
            return 0
        fi

        compile_box86_or_64
    fi

    echo -e "\n\nInstalling ${BOX_VERSION}..."
    download_and_extract "$BINARY_BOX_URL" "$HOME"
    cd "$HOME"/${BOX_VERSION}/build || exit 1
    sudo make install
    echo
    ${BOX_VERSION} -v
    echo -e "\n${BOX_VERSION} has been installed."
}

generate_icon_winetricks() {
    if [[ ! -e /usr/local/bin/winetricks ]]; then
        return 0
    fi

    echo -e "\nGenerating icon...\n"
    if [[ ! -e ~/.local/share/applications/winetricks.desktop ]]; then
        cat <<EOF >~/.local/share/applications/winetricks.desktop
[Desktop Entry]
Name=Winetricks
Comment=Work around problems and install applications under Wine
Exec=env BOX86_NOBANNER=1 winetricks --gui
Terminal=false
Icon=B13E_wscript.0
Type=Application
Categories=Utility;
EOF
    fi
}

# https://github.com/ptitSeb/box86/blob/master/docs/X86WINE.md
install_winex86() {
    local WINE_PKG_I386
    local WINE_PKG
    local DEBIAN_F_PKGS_URL
    local WINETRICKS_URL
    WINE_PKG_I386="https://dl.winehq.org/wine-builds/debian/dists/buster/main/binary-i386/wine-devel-i386_6.8~buster-1_i386.deb"
    WINE_PKG="https://dl.winehq.org/wine-builds/debian/dists/buster/main/binary-i386/wine-devel_6.8~buster-1_i386.deb"
    DEBIAN_F_PKGS_URL="http://ftp.us.debian.org/debian/pool/main/f/faudio/"
    WINETRICKS_URL="https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks"

    cd || exit 1

    echo -e "Backing old wine versions to ~/wine-old and /usr/local/bin/wine*old...\n"
    sudo rm -rf ~/wine-old ~/.wine-old /usr/local/bin/wine-old /usr/local/bin/wineboot-old /usr/local/bin/winecfg-old /usr/local/bin/wineserver-old
    [[ -d ~/wine ]] && sudo mv ~/wine ~/wine-old
    [[ -d ~/.wine ]] && sudo mv ~/.wine ~/.wine-old
    [[ -e /usr/local/bin/wine ]] && sudo mv /usr/local/bin/wine /usr/local/bin/wine-old
    [[ -e /usr/local/bin/wineboot ]] && sudo mv /usr/local/bin/wineboot /usr/local/bin/wineboot-old
    [[ -e /usr/local/bin/winecfg ]] && sudo mv /usr/local/bin/winecfg /usr/local/bin/winecfg-old
    [[ -e /usr/local/bin/wineserver ]] && sudo mv /usr/local/bin/wineserver /usr/local/bin/wineserver-old

    echo -e "Downloading...\n"
    wget -q -O wine_devel.deb "$WINE_PKG_I386"
    wget -q -O wine.deb "$WINE_PKG"
    wget -q -r -l1 -np -nd -A "libfaudio0_*~bpo10+1_i386.deb" "$DEBIAN_F_PKGS_URL"

    echo -e "Extract,clean & installing files/pkgs...\n"
    dpkg-deb -x ./wine_devel.deb wine-installer
    dpkg-deb -x ./wine.deb wine-installer
    dpkg-deb -xv ./libfaudio0_*~bpo10+1_i386.deb libfaudio

    mv ./wine-installer/opt/wine* ~/wine
    sudo cp -TRv libfaudio/usr/ /usr/
    rm -rf wine*.deb wine-installer libfaudio0_*~bpo10+1_i386.deb libfaudio
    #sudo rm /usr/local/bin/wine /usr/local/bin/wineboot /usr/local/bin/winecfg /usr/local/bin/wineserver

    echo -e "\nGenerating shortcuts at /usr/local/bin/wine*...\n"
    echo -e '#!/bin/bash\nsetarch linux32 -L '"$HOME/wine/bin/wine "'"$@"' | sudo tee -a /usr/local/bin/wine >/dev/null
    if ! is_kernel_64_bits; then
        sudo rm /usr/local/bin/wine
        sudo ln -f -s ~/wine/bin/wine /usr/local/bin/wine
    fi
    sudo ln -f -s ~/wine/bin/wineboot /usr/local/bin/wineboot
    sudo ln -f -s ~/wine/bin/winecfg /usr/local/bin/winecfg
    sudo ln -f -s ~/wine/bin/wineserver /usr/local/bin/wineserver
    sudo chmod +x /usr/local/bin/wine /usr/local/bin/wineboot /usr/local/bin/winecfg /usr/local/bin/wineserver

    echo -e "Installing some essential components for you..."
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq libstb0 cabextract </dev/null >/dev/null

    wget -q "$WINETRICKS_URL"
    sudo chmod +x winetricks
    sudo mv winetricks /usr/local/bin/
    generate_icon_winetricks

    wine wineboot
}

install_mesa() {
    local BINARY_URL
    BINARY_URL="https://misapuntesde.com/rpi_share/pilabs/mesa.tar.gz"

    if [ -d ~/mesa ]; then
        echo -e "\n~/mesa is already installed, skipping..."
        return 0
    fi

    echo -e "\n\nInstalling Mesa lib...\n"
    download_and_extract "$BINARY_URL" "$HOME"
}

installMonolibs() {
    local BINARY_URL
    BINARY_URL="https://misapuntesde.com/rpi_share/pilabs/monolibs.tar.gz"

    if [[ ! -d $HOME/monolibs ]]; then
        wget -O "$HOME/monolibs.tar.gz" "$BINARY_URL"
        extract "$HOME/monolibs.tar.gz" && rm -
    fi
}

#
# Get the current locale from the system
#
getSystemLocale() {
    local LOCALE
    LOCALE=$(locale | grep LANGUAGE | cut -d= -f2 | cut -d_ -f1)
    echo "$LOCALE"
}

#
# Check if a package is installed or not
#
isPackageInstalled() {
    if dpkg -s "$1" &>/dev/null; then
        true
    else
        false
    fi
}

#
# Install packages if missing
#
install_packages_if_missing() {
    check_dependencies "$@"
}

#
# Get your current IP in the Lan
#
get_ip() {
    local IP
    IP=$(hostname -I | awk '{print $1}')
    echo "$IP"
}

#
# Delete directory
#
delete_dir() {
    if [ -w "$1" ]; then
        rm -rf "$1"
    else
        if [ "$1" == "/" ]; then
            echo "/ protection enabled. You can't delete it!. Exiting..."
            exit
        fi
        sudo rm -rf "$1"
    fi
    echo "$1 deleted."
}

#
# Check directory exist and ask for deletion
#
directory_exist() {
    if [[ -d "$1" ]]; then
        read -p "Directory already exist. Delete it and its content (recursive) (y/n)?: " option
        case "$option" in
        y*) delete_dir "$1" ;;
        n*) return ;;
        esac
    fi
}

#
# Get the distribution name
#
get_distro_name() {
    local DISTRO
    DISTRO=$(lsb_release -si)
    echo "$DISTRO"
}

#
# Get the name of a file from url
#
get_file_name_from_path() {
    local SUFFIX
    local FILE_NAME
    SUFFIX="?dl=0"
    FILE_NAME=$(basename "$1" | sed -e "s/$SUFFIX$//")

    if [ "$FILE_NAME" == "" ]; then
        echo -e "\nSorry, the file you trying to download is not available."
        remove_unneeded_helper # Maybe an old helper.sh is loaded. Delete it.
        exit_message
        exit 1
    fi

    echo "$FILE_NAME"
}

#
# Get a valid url if hosters change it constantly
#
get_valid_path() {
    local DATA_URL
    local TEMP_DATA_URL
    DATA_URL=$1

    if [[ $DATA_URL == https://anonfiles.com* ]]; then
        DATA_URL=https://cdn$(curl -s "$1" | grep -Po '(?<=https://cdn).*(?=">)')
    fi

    if [[ $DATA_URL == https://e.pcloud.link* ]]; then
        TEMP_DATA_URL=$(curl -s "$1" | grep -m 1 -Po '(?<="downloadlink": ").*(?=",)')
        DATA_URL="${TEMP_DATA_URL//\\/}"
    fi

    echo "$DATA_URL"
}

#
# Download a file to custom directory
# $1 url
# $2 destination directory
#
download_file() {
    local DATA_URL
    local DESTINATION_DIR
    local FILE_NAME

    DATA_URL=$(get_valid_path "$1")
    DESTINATION_DIR="$2"
    FILE_NAME=$(get_file_name_from_path "$DATA_URL")

    use_data_from "$DATA_URL" "$DESTINATION_DIR" "$FILE_NAME"
}

#
# Download a file and extract it
# $1 url
# $2 destination directory
#
# TODO Install uncompressor pkg if not installed (Ex. if you have .7z file, install p7zip-full)
#
download_and_extract() {
    local DATA_URL
    local DESTINATION_DIR
    local FILE_NAME

    DATA_URL=$(get_valid_path "$1")
    DESTINATION_DIR="$2"
    FILE_NAME=$(get_file_name_from_path "$DATA_URL")

    use_data_from "$DATA_URL" "$DESTINATION_DIR" "$FILE_NAME"

    if [ ! -e "$DESTINATION_DIR/$FILE_NAME" ]; then
        echo -e "\nSomething is wrong, aborting..."
        exit_message
        exit 1
    fi

    if [[ ! -d $DATA_URL ]]; then
        echo -e "\nExtracting..."
        cd "$DESTINATION_DIR" || exit 1
        # TODO Refactor: extract should have a second argument "$DESTINATION_DIR" and remove copying local file at function use_data_from
        extract "$FILE_NAME"
    fi

    if is_URL "$DATA_URL"; then
        rm -f "$DESTINATION_DIR"/"$FILE_NAME"
    fi
}

#
# Download a file from URLs OR copy from local filesystem (file/directory)
# NOTE: The name of the function is a crap. Ideas? :)
# $1 url/local or file/directory
# $2 destination directory
# $3 file name
#
use_data_from() {
    local DATA_URL
    local DESTINATION_DIR
    local FILE_NAME
    local COMMAND
    local DOWNLOAD_MANAGER

    DATA_URL="$1"
    DESTINATION_DIR="$2"
    FILE_NAME="$3"
    DOWNLOAD_MANAGER="wget"
    COMMAND=$(set_download_manager $DOWNLOAD_MANAGER)

    [ ! -d "$DESTINATION_DIR" ] && mkdir -p "$DESTINATION_DIR"

    if [[ $DATA_URL == http* ]]; then
        [ ! -w "$DESTINATION_DIR" ] && COMMAND="sudo $COMMAND"
        echo -e "\nDownloading...\n"
        cd "$DESTINATION_DIR" || exit 1
        ${COMMAND} "$FILE_NAME" -c "$DATA_URL"
    elif [[ -e "$DATA_URL" ]]; then
        # TODO Refactor. We don't need to copy if it's a local file or directory
        echo -e "\nCopying from local storage...\n"
        cp -ur "$DATA_URL" "$DESTINATION_DIR"
    fi
}

set_download_manager() {
    if [[ $1 == 'aria2c' ]]; then
        install_packages_if_missing aria2
        echo "aria2c -x16 --max-tries=0 --check-certificate=false --file-allocation=none -o"
    fi

    echo "wget -q --show-progress --no-check-certificate -O"
}

#
# Download a .deb and install it
# $1 url
#
download_and_install() {
    local FILE
    FILE=$(get_file_name_from_path "$1")

    download_file "$1" /tmp
    echo -e "\nInstalling necessary custom package..." && sudo apt --fix-broken install /tmp/"$FILE"
    [ -e /tmp/"$FILE" ] && rm -f rm /tmp/"$FILE"
}

#
# Backup a file as user or root
#
file_backup() {
    if [[ -f "$1" ]]; then
        if [[ -w $(dirname "$1") ]]; then
            cp "$1"{,.bak}
        else
            sudo cp "$1"{,.bak}
        fi
        echo -e "\nBacked up the file at: $1.bak"
    fi
}

#
# Modify the max file size in your php.ini
#
php_file_max_size() {
    read -p "Input the max file size (MB) you can upload throught the server and press [ENTER]. (Example: 8,512,...): " input
    if is_integer "${input}"; then
        INI_FILE=$(php --ini | grep 'Loaded Configuration File:' | awk '{print $4}')
        echo "php.ini = $INI_FILE"
        file_backup "$INI_FILE"

        sudo sed -i "s/post_max_size.*/post_max_size = ${input}M/" "$INI_FILE"
        cat "$INI_FILE" | grep 'post_max_size'
    else
        echo "Sorry, ${input} is not a correct value. No file was modified."
    fi
}

#
# Intall Node.js (all versions)
#
install_node() {
    local NODE_VERSION

    if which node >/dev/null; then
        read -p "Warning!: Node.js already installed (Version $(node -v)). Do you want to uninstall it (y/n)?: " option
        case "$option" in
        y*)
            sudo apt-get remove -y nodejs
            sudo rm -rf /usr/local/{lib/node{,/.npm,_modules},bin,share/man}/{npm*,node*,man1/node*}
            ;;
        n*) return ;;
        esac
    fi

    cd ~ || exit
    if [[ -z "$1" ]]; then
        read -p "Type the Node.js version you want to install: 16, 15, 14 (recommended), 13, ...10, followed by [ENTER]: " NODE_VERSION
    else
        NODE_VERSION="$1"
    fi

    curl -sL https://deb.nodesource.com/setup_"${NODE_VERSION}".x | sudo -E bash -
    echo -e "\nInstalling Node.js and dependencies, please wait...\n"
    sudo apt install -y nodejs build-essential libssl-dev libx11-dev
    echo -e "\nReboot or logout to use it."
}

#
# Install Yarn for Node
#
install_yarn() {
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt update && sudo apt install -y yarn
}

#
# Check what is your board
#
check_board() {
    if [[ $(cat /proc/cpuinfo | grep 'ODROIDC') ]]; then
        MODEL="ODROID-C1"
    elif [[ $(cat /proc/cpuinfo | grep 'BCM2708\|BCM2709\|BCM2835\|BCM2711') ]]; then
        MODEL="Raspberry Pi"
    elif [ "$(uname -n)" = "debian" ]; then
        MODEL="Debian"
    elif [[ $(grep orangepizero /etc/armbian-release) ]]; then
        MODEL="Orange Pi Zero"
    else
        MODEL="UNKNOWN"
        dialog --title '[ WARNING! ]' --msgbox "Board or Operating System not compatible.\nUse at your own risk." 6 45
    fi
}

#
# Fix for SDL
#
SDL_fix_Rpi() {
    echo "Applying fix to SDL on Raspberry Pi 2, please wait..."
    if [[ $(cat /proc/cpuinfo | grep 'BCM2709') && $(stat -c %y /usr/lib/arm-linux-gnueabihf/libSDL-1.2.so.0.11.4 | grep '2012') ]]; then
        wget -P /tmp https://malus.exotica.org.uk/~buzz/pi/sdl/sdl1/deb/rpi1/libsdl1.2debian_1.2.15-8rpi_armhf.deb
        sudo dpkg -i /tmp/libsdl1.2debian_1.2.15-8rpi_armhf.deb
        sudo rm /tmp/libsdl1.2debian_1.2.15-8rpi_armhf.deb
    fi
}

#
# Your current CPU temperature
#
check_temperature() {
    if [ -f /opt/vc/bin/vcgencmd ]; then
        TEMPC="| $(/opt/vc/bin/vcgencmd measure_temp | awk '{print $1"º"}') "
    elif [ -f /sys/devices/virtual/thermal/thermal_zone0/temp ]; then
        TEMPC="| TEMP: $(cat /sys/devices/virtual/thermal/thermal_zone0/temp | cut -c1-2 | awk '{print $1"º"}') "
    else
        TEMPC=''
    fi
}

#
# Show extend CPU info
#
get_cpu_frequency() {
    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq ]; then
        echo "$(expr "$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)" / 1000)"
    else
        echo "?"
    fi
}

#
# Check if internet is available
#
check_internet_available() {
    # Make sure we have internet conection
    if [ ! "$NOINTERNETCHECK" = 1 ]; then
        PINGOUTPUT=$(ping -c 1 8.8.8.8 >/dev/null && echo '...')
        if [ ! "$PINGOUTPUT" = '...' ]; then
            echo -e "\nInternet connection required. Causes:\n\n · Check your network.\n · Weak WiFi signal?.\n · Try no check internet connection parameter (-ni): cd ~/piKiss && ./piKiss.sh -ni\n"
            read -p "Press [Enter] to exit..."
            exit 1
        fi
    fi
    echo "$PINGOUTPUT"
}

#
# Check if passed variable is an integer
# TODO: Improve it
#
is_integer() {
    return $(test "$@" -eq "$@" >/dev/null 2>&1)
}

show_dialog() {
    local h=${1-10}     # box height default 10
    local w=${2-41}     # box width default 41
    local t=${3-Output} # box title

    while true; do

        dialog --clear \
            --title "[ M A I N - M E N U ]" \
            --menu "You can use the UP/DOWN arrow keys, the first letter of the choice as a hot key, or the number keys 1-4 to choose an option." ${h} ${w} \
            "$(<$OUTPUT)"
        Exit "Exit to the shell" 2>"$(<$INPUT)"

        menuitem=$(<"${INPUT}")

        case $menuitem in
        Tweaks) smTweaks ;;
        Games) smGames ;;
        Emula) smEmulators ;;
        Info) smInfo ;;
        Multimedia) smMultimedia ;;
        Configure) smConfigure ;;
        Internet) smInternet ;;
        Server) smServer ;;
        Others) smOthers ;;
        Exit) echo -e "\nThanks for visiting https://misapuntesde.com" && exit ;;
        1)
            echo -e "\nCancel pressed." && exit
            ;;
        255)
            echo -e "\nESC pressed." && exit
            ;;
        esac
    done
}

make_desktop_entry() {
    if [[ ! -e "$HOME"/.local/share/applications/pikiss.desktop ]]; then
        cat <<EOF >~/.local/share/applications/pikiss.desktop
[Desktop Entry]
Name=PiKISS
Exec=${PWD}/piKiss.sh
Icon=${PWD}/icons/pikiss_32.png
Path=${PWD}/
Type=Application
Comment=A bunch of scripts with menu to make your life easier
Categories=ConsoleOnly;Utility;System;
Terminal=true
X-KeepTerminal=true
EOF
        restart_panel
    fi
}

exit_message() {
    echo
    read -p "Press [Enter] to go back to the menu..."
    exit 1
}

validate_url() {
    if [[ $(wget -S --spider $1 2>&1 | grep 'HTTP/1.1 200 OK') ]]; then echo "true"; fi
}

install_joypad() {
    echo -e "\nDo you want to install joystick/pad packages?"
    read -p "Agree (y/n)? " option
    case "$option" in
    y*)
        dpkg -l | grep ^"ii  joystick" >/dev/null || sudo apt-get install -y joystick jstest-gtk
        jscal /dev/input/js0
        # Check if X is running
        if ! xset q &>/dev/null; then
            jstest /dev/input/js0
        else
            jstest-gtk
        fi
        ;;
    esac

    echo "Done!"
}

package_check() {
    dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -c "ok installed"
}

check_dependencies() {
    INSTALLER_DEPS=("$@")
    for i in "${INSTALLER_DEPS[@]}"; do
        if ! package_check "$i" -eq 0 >/dev/null; then
            sudo apt install -y "$i"
        fi
    done
}

#
# Check last time 'apt-get update' and run it if has passed 7 days
#
check_update() {
    local A_WEEK_IN_SECONDS
    A_WEEK_IN_SECONDS=604800
    NOW=$(date +%s)
    LAST_UPDATE_AT=$(stat -c %y /var/cache/apt/ | awk '{print $1,$2}' | date -d $? +%s)
    RESULT=$((NOW - LAST_UPDATE_AT))

    if [[ $RESULT -ge $A_WEEK_IN_SECONDS ]]; then
        sudo apt-get -qq update
    fi
}

last_update_repo() {
    DATENOW=$(date +"%d-%b-%y")

    if [ -e "checkupdate.txt" ]; then
        CHECKUPDATE=$(cat checkupdate.txt)

        if [[ $CHECKUPDATE -ge $DATENOW ]]; then
            echo "Update repo: NO"
            return 0
        fi
    fi

    echo "Update repo: YES"
    (echo "$DATENOW" >checkupdate.txt)
    sudo apt-get -qq update
}

check_update_pikiss() {
    if [[ "$CHK_PIKISS_UPDATE" -eq 1 ]]; then
        return 1
    fi
    git fetch
    local IS_UP_TO_DATE
    IS_UP_TO_DATE=$(git diff --name-only origin/master)
    if [[ $IS_UP_TO_DATE ]]; then
        echo -e "\n New version available!\n\n · Installing updates...\n"
        git fetch --all
        git reset --hard origin/master
        git pull --ff-only origin master
        echo
        echo -e "You need to run the program again.\n"
        read -p "Press [ENTER] to exit."
        exit 1
    fi
}

function is_missing_dialog_pkg() {
    if [ ! -f /usr/bin/dialog ]; then
        while true; do
            read -p "Missing 'dialog' package. Do you wish to let me try to install it for you? (aprox. 1.3 kB) [y/n] " yn
            case $yn in
            [Yy]*)
                sudo apt install -y dialog
                break
                ;;
            [Nn]*)
                echo "Please install 'dialog' package to continue."
                exit 1
                ;;
            *) echo "Please answer (y)es or (n)o." ;;
            esac
        done
    fi
}

get_raspberry_pi_model_number() {
    awk </proc/device-tree/model '{print $3}' | head -c 1
}

#
# Compile SDL2 and some dependencies
#
compile_sdl2() {
    if [ ! -e /usr/include/SDL2 ]; then
        clear && echo "Compiling SDL2, please wait about 5 minutes..."
        mkdir -p "$HOME"/sc && cd "$_" || exit
        wget https://www.libsdl.org/release/SDL2-2.0.10.zip
        unzip SDL2-2.0.10.zip && cd SDL2-2.0.10 || exit
        ./autogen.sh
        ./configure --disable-pulseaudio --disable-esd --disable-video-wayland --disable-video-opengl --host=arm-raspberry-linux-gnueabihf --prefix=/usr
        make_with_all_cores
        sudo make install
        echo "Done!"
    else
        echo -e "\n· SDL2 already installed.\n"
    fi
}

compile_sdl2_image() {
    clear && echo "Compiling SDL2_image, please wait..."
    cd "$HOME"/sc || exit
    wget https://www.libsdl.org/projects/SDL_image/release/SDL2_image-2.0.5.tar.gz
    tar zxvf SDL2_image-2.0.5.tar.gz && cd SDL2_image-2.0.5 || exit 1
    ./autogen.sh
    ./configure --prefix=/usr
    make_with_all_cores
    sudo make install
}

compile_sdl2_mixer() {
    clear && echo "Compiling SDL2_mixer, please wait..."
    cd "$HOME"/sc || exit
    wget https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-2.0.4.tar.gz
    tar zxvf SDL2_mixer-2.0.4.tar.gz && cd SDL2_mixer-2.0.4 || exit 1
    ./autogen.sh
    ./configure --prefix=/usr
    make_with_all_cores
    sudo make install
}

compile_sdl2_ttf() {
    clear && echo "Compiling SDL2_ttf, please wait..."
    cd "$HOME"/sc || exit
    wget https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-2.0.15.tar.gz
    tar zxvf SDL2_ttf-2.0.15.tar.gz && cd SDL2_ttf-2.0.15 || exit 1
    ./autogen.sh
    ./configure --prefix=/usr
    make_with_all_cores
    sudo make install
}

compile_sdl2_net() {
    clear && echo "Compiling SDL2_net, please wait..."
    cd "$HOME"/sc || exit
    wget https://www.libsdl.org/projects/SDL_net/release/SDL2_net-2.0.1.tar.gz
    tar zxvf SDL2_net-2.0.1.tar.gz && cd SDL2_net-2.0.1 || exit 1
    ./autogen.sh
    ./configure --prefix=/usr
    make_with_all_cores
    sudo make install
}

#
# Install Apache 2
#
install_apache2() {
    sudo apt-get install -y apache2 libapache2-mod-php7.0
    sudo sh -c 'echo "ServerSignature Off\nServerTokens Prod" >> /etc/apache2/apache2.conf'
    sudo chown -R www-data:www-data /var/www/html
    sudo systemctl restart apache2
    # Run on each new installed framework
    # sudo find /var/www/html -type d -exec chmod 755 {} \;
    # sudo find /var/www/html -type f -exec chmod 644 {} \;
}

#
# Add latest php repository
#
add_php_repository() {
    if [[ -e /etc/apt/sources.list.d/php.list ]]; then
        return 0
    fi
    sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    sudo sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
    sudo apt-get -qq update
}

#
# Upgrade Distribution
#
upgrade_dist() {
    echo -e "\nUpgrading distribution...\n"
    sudo apt-get -qq update && sudo apt-get -y upgrade
}

exists_magic_file() {
    if [[ -e $PIKISS_MAGIC_AIR_COPY_PATH ]]; then
        true
    else
        false
    fi
}

#
# Message use the MagicAirCopy® technology
#
message_magic_air_copy() {
    if ! exists_magic_file; then
        false
        return
    fi

    if [[ $1 == "" ]]; then
        echo -e "\nNo game data files found for this game/app inside the file $PIKISS_MAGIC_AIR_COPY_PATH."
        false
        return
    fi

    if is_URL "$1" && is_URL_down "$1"; then
        echo -e "\nData files not found. Check if $1 exists and it's a valid file/dir/hoster..."
        false
        return
    fi

    echo -e "\nFound $PIKISS_MAGIC_AIR_COPY_PATH...\n"
    echo "I'm trying to move the data files FROM YOUR original copy to destination directory using the technology MagicAirCopy® (｀-´)⊃━☆ﾟ.*･｡ﾟ"
    true
}

#
# Extract row from a file
#
extract_path_from_file() {
    local MAGIC_FILE_PATH
    MAGIC_FILE_PATH="${PIKISS_DIR}/res/magic-air-copy-pikiss.txt"

    if [[ ! -f $MAGIC_FILE_PATH ]]; then
        echo ""
        exit 1
    fi

    grep ^"$1=" "$MAGIC_FILE_PATH" | awk -F "$1=" '{print $2}'
}

#
# Extract all kind of compressed files
#
extract() {
    if [ -f "$1" ]; then
        case "$1" in
        *.tar.bz2 | *.tbz2) tar xjf "$1" ;;
        *.tar.gz | *.tgz) tar xzf "$1" ;;
        *.tar.xz) tar xf "$1" ;;
        *.xz) xz --decompress "$1" ;;
        *.bz2) tar jxf "$1" ;;
        *.rar) unrar x "$1" ;;
        *.gz) gunzip "$1" ;;
        *.tar) tar xvf "$1" ;;
        *.zip) unzip -qq -o "$1" ;;
        *.Z) uncompress "$1" ;;
        *.7z) p7zip -d "$1" ;;
        *.exe) cabextract "$1" ;;
        *) echo "'$1': unrecognized file compression" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

#
# exit PiKISS
#
exit_pikiss() {
    echo -e "\nSee you soon.\nPiKISS is a software maintained by Jose Cerrejon.\nYou can find me here (CTRL + Click):\n\n · PiKISS Repository: https://github.com/jmcerrejon/PiKISS\n · Paypal: https://paypal.me/jmcerrejon\n · Twitter: https://twitter.com/ulysess10\n · Discord Server (Pi Labs): https://discord.gg/Y7WFeC5\n · Email: ulysess@gmail.com\n\n · Wanna be my Patron?: https://www.patreon.com/cerrejon?fan_landing=true"
    exit
}

#
# Compile with all cores
#
make_with_all_cores() {
    echo -e "\n Compiling..."

    if [ "$(uname -m)" == 'armv7l' ]; then
        time make -j"$(nproc)" OPTOPT="-fsigned-char -marm -march=armv8-a+crc -mtune=cortex-a72 -mfpu=neon-fp-armv8 -mfloat-abi=hard" "$@"
    else
        time make -j"$(nproc)" "$@"
    fi

    echo
}

#
#
# Uninstall PiKISS
#
uninstall_pikiss() {
    clear
    local PIKISS_SHORTCUT_PATH
    local PIKISS_PATH
    PIKISS_SHORTCUT_PATH="$HOME/.local/share/applications/pikiss.desktop"
    PIKISS_PATH="${PWD}"
    echo -e "The path to be delete is: $PIKISS_PATH\n"

    if [[ "$PIKISS_PATH" != *piKiss ]]; then
        echo -e "\nSomething is wrong. I can't uninstall. Contact with me."
        exit 1
    fi

    read -p "Is that correct and you want to uninstall PiKISS (Y/n)? " response
    if [[ $response =~ [Nn] ]]; then
        return 0
    fi

    echo -e "\nUninstalling..."
    rm -f "$PIKISS_SHORTCUT_PATH"
    rm -rf "$PIKISS_PATH"
    echo -e "\nPiKISS uninstall completed."
    exit_pikiss
}

#
# Return (true) if kernel is 64 bits
#
is_kernel_64_bits() {
    if [ "$(uname -m)" == "aarch64" ]; then
        true
    else
        false
    fi
}

#
# Return (true) if userspace is 64 bits
#
is_userspace_64_bits() {
    if [ "$(getconf LONG_BIT)" == "64" ]; then
        true
    else
        false
    fi
}

install_nspawn_64_if_not_installed() {
    if is_userspace_64_bits; then
        echo "nspawn-64 not needed."
        return 0
    fi
    if isPackageInstalled raspbian-nspawn-64; then
        return 0
    fi
    sudo apt install -y raspbian-nspawn-64
}

#
# Return (true) if it's enabled KMS on /boot/config.txt
#
check_is_enabled_kms() {
    local BOOTCFG_PATH
    BOOTCFG_PATH="/boot/config.txt"

    if grep -q "^dtoverlay=" "$BOOTCFG_PATH"; then
        return 1
    else
        return 0
    fi
}

#
# Set the legacy driver and comment dtoverlay parameter
#
set_legacy_driver() {
    local BOOTCFG_PATH
    BOOTCFG_PATH="/boot/config.txt"

    if grep -q "^dtoverlay=" "$BOOTCFG_PATH"; then
        echo -e "\nCommenting dtoverlay on $BOOTCFG_PATH...\n"
        file_backup "$BOOTCFG_PATH"
        sudo sed -i "s/^dtoverlay=vc4/#dtoverlay=vc4/g" "$BOOTCFG_PATH"
        echo -e "\nWhen you want to enable KMS again, change the value with sudo raspi-config > Advanced Options > GL Driver.\nYou must to reboot."
    fi
}

#
# Set a new gpu_mem value parameter
#
set_GPU_memory() {
    local BOOTCFG_PATH
    local GPU_SIZE
    BOOTCFG_PATH="/boot/config.txt"
    [ $# -eq 0 ] && GPU_SIZE=128 || GPU_SIZE="$1"

    file_backup "$BOOTCFG_PATH"

    echo -e "\nSetting gpu_mem to $GPU_SIZE MB on $BOOTCFG_PATH...\n"
    if grep -q "gpu_mem" "$BOOTCFG_PATH"; then
        sudo sed -i "s/gpu_mem.*/gpu_mem=$GPU_SIZE/g" "$BOOTCFG_PATH"
    else
        sudo -- bash -c "echo 'gpu_mem=$GPU_SIZE' >> $BOOTCFG_PATH"
    fi
}

#
# Ket two key string from the keyboard layout
#
get_keyboard_layout() {
    setxkbmap -query | grep layout | awk -F: '{print $2}' | sed 's/^ *//g'
}

#
# Remove unnecessary helper.sh
#
remove_unneeded_helper() {
    [[ -f ~/helper.sh ]] && rm ~/helper.sh
}

#
# Install or update Rust
#
install_or_update_rust() {
    local RUST_PATH
    RUST_PATH="https://sh.rustup.rs"

    if [[ -d ~/.cargo ]]; then
        rustup update stable
        exit 0
    fi

    curl --proto '=https' --tlsv1.2 -sSf "$RUST_PATH" | sh
    PATH=$PATH:$HOME/.cargo/bin

    if [ "$(grep -c .cargo ~/.bashrc)" -eq 0 ]; then
        echo "PATH=$PATH:$HOME/.cargo/bin" >>~/.bashrc
    fi
}

#
# Return boolean if url is not online
#
is_URL_down() {
    local URL

    if ! isPackageInstalled httpie; then
        sudo apt-get install -qq httpie </dev/null >/dev/null
    fi
    URL=$(http --verify=no -h "$1" | awk 'NR==1' | awk '{print $2}')

    if [ "$URL" != 200 ]; then
        true
    else
        false
    fi
}

install_script_message() {
    echo -e "PiKISS is going to install this software for you ;)"
}

#
# Return true if is a URL
#
is_URL() {
    if [[ $1 == http://* ]] || [[ $1 == https://* ]]; then
        true
    else
        false
    fi
}

cmd_reboot() {
    echo
    read -p "Now the system is going to reboot. Press [ENTER] to reboot..."
    sudo reboot
}

upgrade() {
    echo -e "\nUpgrading your distro...\n"
    sudo apt-get -qq update && sudo apt-get -y dist-upgrade
}

make_install_compiled_app() {
    echo
    read -p "Do you want to install it? (y/N) " response
    if [[ $response =~ [Yy] ]]; then
        sudo make install
    fi
}

install_backports() {
    if [[ -e /etc/apt/sources.list.d/debian-backports.list ]]; then
        return 0
    fi
    echo -e "\nInstalling buster-backports...\n"
    echo 'deb https://deb.debian.org/debian buster-backports main contrib non-free' | sudo tee -a /etc/apt/sources.list.d/debian-backports.list
    gpg --recv-keys --keyserver ipv4.pool.sks-keyservers.net 04EE7237B7D453EC
    gpg --recv-keys --keyserver ipv4.pool.sks-keyservers.net 648ACFD622F3D138
    gpg --export 04EE7237B7D453EC | sudo apt-key add -
    gpg --export 648ACFD622F3D138 | sudo apt-key add -
    sudo apt-get update
}

remove_backports() {
    local backport_path
    backport_path=/etc/apt/sources.list.d/debian-backports.list

    echo -e "\Removing buster-backports...\n"
    if [[ -e $backport_path ]]; then
        sudo rm "$backport_path"
    fi
}

install_meson() {
    echo -e "\nChecking if meson is installed...\n"
    if ! pip3 list | grep -F meson &>/dev/null; then
        isPackageInstalled meson && sudo apt-get remove -y meson
        sudo pip3 install meson --force-reinstall
    fi
}

install_nginx() {
    local PACKAGES
    local DEFAULT_NGINX_SITES_AVAILABLE_DIR
    local NGINX_DEFAULT_SITE_PATH
    local PHP_VERSION
    PHP_VERSION=$(get_PHP_minor_version)
    DEFAULT_NGINX_SITES_AVAILABLE_DIR="/etc/nginx/sites-available/"
    NGINX_DEFAULT_SITE_PATH="/etc/nginx/sites-available/default"
    PACKAGES=(nginx-light)

    check_update
    install_packages_if_missing "${PACKAGES[@]}"
    sudo usermod -aG www-data "$USER"
    sudo chown -R "$USER":www-data /var/www/
    echo -e "\nWARNING: Setting up writable the directory $DEFAULT_NGINX_SITES_AVAILABLE_DIR by $USER. Take it into account If you are going to expose the Pi for serve sites on the internet."
    sudo chown -R "$USER":www-data "$DEFAULT_NGINX_SITES_AVAILABLE_DIR"
    # Give PHP support
    sudo sed -i "s/index index.html/index index.php index.html/" "$NGINX_DEFAULT_SITE_PATH"
    sudo sed -i "s/^[[:blank:]]#*[[:blank:]]*include snippets/                include snippets/" "$NGINX_DEFAULT_SITE_PATH"
    # sudo sed -i "s/^[[:blank:]]#*[[:blank:]]*fastcgi_pass/                fastcgi_pass/" "$NGINX_DEFAULT_SITE_PATH"
    # sudo sed -i "s/php7.3-fpm.sock/php${PHP_VERSION}-fpm.sock/" "$NGINX_DEFAULT_SITE_PATH"
    sudo service "php${PHP_VERSION}-fpm" restart
    sudo systemctl restart nginx
}

# INFO Not tested
letsencrypt() {
    sudo add-apt-repository ppa:certbot/certbot
    sudo apt install python-certbot-nginx

    sudo certbot --nginx -d "$1".com -d www."$1".com
}

uninstall_mariadb() {
    local DB_BIN_PATH
    local PACKAGES
    DB_BIN_PATH="/usr/bin/mysql"
    PACKAGES=(mariadb-server* mariadb-client*)

    if [[ ! -e $DB_BIN_PATH ]]; then
        return 0
    fi

    echo
    read -p "MariaDB is already installed. Do you want to uninstall it? (Y/n) " response
    if [[ $response =~ [Nn] ]]; then
        return 0
    fi

    sudo systemctl stop mysql
    sudo apt remove -y --purge "${PACKAGES[@]}"
}

# INFO We can't install MySQL from official repository
install_mariadb() {
    local RANDOM_USER_PASSWORD
    local PACKAGES
    PACKAGES=(mariadb-server mariadb-client)

    echo -e "\nInstalling MariaDB...\n"
    install_packages_if_missing "${PACKAGES[@]}"
    sudo systemctl start mariadb
    sudo systemctl enable mariadb
    echo -e "Securing DB..."
    sudo mysql_secure_installation
    echo
    read -p "Do you want to add the current user $USER to MariaDB (recommended)? (y/N) " response
    if [[ $response =~ [Yy] ]]; then
        RANDOM_USER_PASSWORD=$(openssl rand -base64 10)
        echo -e "\nYou user password (write it down in a safe place): ${RANDOM_USER_PASSWORD}\n"
        sudo mysql -e "CREATE USER '${USER}'@'%' IDENTIFIED BY '${RANDOM_USER_PASSWORD}'; GRANT ALL PRIVILEGES ON *.* TO '${USER}'@'%'; FLUSH PRIVILEGES;"
    fi
    sudo service mysql restart
}

get_PHP_minor_version() {
    if which php >/dev/null; then
        php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d"."
    fi
}

install_php() {
    COMMON_PACKAGES_7=(software-properties-common php7.4-fpm php7.4-mysql php7.4-mbstring php7.4-xml php7.4-bcmath php7.4-cli php7.4-gd php7.4-curl php7.4-common)
    COMMON_PACKAGES_8=(software-properties-common php8.1-fpm php8.1-mysql php8.1-mbstring php8.1-xml php8.1-bcmath php8.1-cli php8.1-gd php8.1-curl php8.1-common)

    add_php_repository

    if [[ -z "$1" ]]; then
        read -p "Choose PHP version 7.4 (stable) or 8.1 (latest)? (7/8) " response
        if [[ $response =~ [7] ]]; then
            echo -e "\nInstalling Packages for PHP 7.4..."
            sudo apt install -y "${COMMON_PACKAGES_7[@]}"
        else
            echo -e "\nInstalling Packages for PHP 8.1..."
            sudo apt install -y "${COMMON_PACKAGES_8[@]}"
        fi
    else
        sudo apt install -y "${COMMON_PACKAGES_7[@]}"
    fi

    # Install composer
    if [[ -e /usr/local/bin/composer ]]; then
        return 0
    fi
    echo -e "\nInstalling Composer..."
    cd /tmp || exit 1
    sudo curl -s https://getcomposer.org/installer | php
    sudo mv "/tmp/composer.phar" /usr/local/bin/composer
}

generate_random_password() {
    openssl rand -base64 12
}

# Thks to https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
get_latest_release() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" |
        grep '"name":' |
        sed -E 's/.*"([^"]+)".*/\1/'
}

open_default_browser() {
    if which chromium-browser >/dev/null; then
        echo -e "\nOpening Browser with site: $1..."
        chromium-browser "$1" &>/dev/null &
    fi
}

get_codename() {
    lsb_release -sc
}

get_pi_version_number() {
    if [[ $MODEL != 'Raspberry Pi' ]]; then
        return
    fi

    awk </proc/device-tree/model '{print $3}'
}

open_file_explorer() {
    if [[ -e /usr/bin/nautilus ]]; then
        nautilus "$1" &>/dev/null &
    elif [[ -e /usr/bin/thunar ]]; then
        thunar "$1" &>/dev/null &
    elif [[ -e /usr/bin/pcmanfm ]]; then
        pcmanfm "$1" &>/dev/null &
    elif [[ -e /usr/bin/nemo ]]; then
        nemo "$1" &>/dev/null &
    elif [[ -e /usr/bin/dolphin ]]; then
        dolphin "$1" &>/dev/null &
    fi
}

get_free_mem() {
    free -h | sed -n 2p | awk '{print $4}'
}

play_media() {
    if which vlc >/dev/null; then
        PLAYER=$(which vlc)
        echo -e "\nOpening vlc with stream: $1..."
        "$PLAYER" "$1" &>/dev/null &
        return 0
    fi
    if which omxplayer >/dev/null; then
        PLAYER=$(which omxplayer)
        echo -e "\nOpening omxplayer with stream: $1..."
        "$PLAYER" "$1" &>/dev/null &
        return 0
    fi
}

restart_panel() {
    if [[ -e /usr/bin/lxpanelctl ]]; then
        echo -e "\nRestarting LXPanel..."
        lxpanelctl restart &>/dev/null
    fi
}

pip_install() {
    INSTALLER_DEPS=("$@")
    for i in "${INSTALLER_DEPS[@]}"; do
        python3 -m pip install "$i"
    done
}
