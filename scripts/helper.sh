#!/bin/bash
#
# Description : Helpers functions
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
#

#
# Fix libGLESv2.so on Raspbian Stretch
#
fixlibGLES() {
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

#
# PI LABS Libraries
#
installBox86() {
    if [ -d ~/box86 ]; then
        echo -e "~/box86 is already installed, skipping..."
        return 0
    fi
    echo -e "\n\nInstalling BOX86 lib...\n"
    local URL_PATH='https://misapuntesde.com/rpi_share/pilabs/box86.tar.gz'
    download_and_extract "$URL_PATH" "$HOME"
}

installGL4ES() {
    if [ -d ~/gl4es ]; then
        echo -e "~/gl4es is already installed, skipping..."
        return 0
    fi
    echo -e "\n\nInstalling GL4ES lib...\n"
    local URL_PATH='https://misapuntesde.com/rpi_share/pilabs/gl4es.tar.gz'
    download_and_extract "$URL_PATH" "$HOME"
}

installMesa() {
    if [ -d ~/mesa ]; then
        echo -e "~/mesa is already installed, skipping..."
        return 0
    fi
    echo -e "\n\nInstalling Mesa lib...\n"
    local URL_PATH='https://misapuntesde.com/rpi_share/pilabs/mesa.tar.gz'
    download_and_extract "$URL_PATH" "$HOME"
}

installMonolibs() {
    local URL_PATH='https://misapuntesde.com/rpi_share/pilabs/monolibs.tar.gz'
    if [ ! -d /home/pi/monolibs ]; then
        wget -O /home/pi/monolibs.tar.gz "$URL_PATH"
        extract /home/pi/monolibs.tar.gz && rm -
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
    dpkg -s "$1" &>/dev/null

    if [ "$?" -eq 0 ]; then
        true
    else
        false
    fi
}

#
# Install packages if missing
#
installPackagesIfMissing() {
    MUST_INSTALL=false
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        MUST_INSTALL=true
    fi

    if [ "$MUST_INSTALL" == false ]; then
        return 0
    fi

    echo -e "\nInstalling dependencies...\n"
    sudo apt install -y "$@"
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
get_file_name_from_url() {
    local SUFFIX
    local FILE
    SUFFIX="?dl=0"
    FILE=$(basename "$1" | sed -e "s/$SUFFIX$//")

    echo "$FILE"
}

#
# Download a file to custom directory
# $1 url
# $2 destination directory
# $3 destination directory
#
download_file() {
    local FILE
    local COMMAND
    FILE="$(get_file_name_from_url $1)"
    COMMAND="wget"

    [ ! -d $2 ] && mkdir -p "$2"
    if [ -w "$2" ]; then
        COMMAND="sudo wget"
    fi
    echo -e "\nDownloading...\n" && ${COMMAND} -q --show-progress -O "$2"/"$FILE" -c "$1"
}

#
# Download a file and extract it
# $1 url
# $2 destination directory
#
download_and_extract() {
    local FILE
    FILE="$(get_file_name_from_url $1)"

    download_file "$1" "$2"
    echo -e "\nExtracting..." && cd "$2" && extract "$FILE"
    [ -e "$2"/"$FILE" ] && rm -f "$2"/"$FILE"
}

#
# Download a .deb and install it
# $1 url
#
download_and_install() {
    local FILE
    FILE="$(get_file_name_from_url $1)"

    download_file "$1" "$2"
    echo -e "\nInstalling..." && sudo dpkg --force-all -i /tmp/"$FILE"
    [ -e /tmp/"$FILE" ] && rm -f rm /tmp/"$FILE"
}

#
# Check if a package is installed in the system
#
is_pkg_installed() {
    dpkg -s "$1" &>/dev/null

    if [ "$?" -eq 0 ]; then
        echo "Package  is installed!"
        return 0
    else
        echo "Package  is NOT installed!"
        return 1
    fi
}

#
# Backup a file as user or root
#
file_backup() {
    if [[ -f "$1" ]]; then
        if [ -w "$(dirname $1)" ]; then
            cp "$1"{,.bak}
        else
            sudo cp "$1"{,.bak}
        fi
        echo "Backed up the file at: $1.bak"
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
    NODE_VERSION="12"
    cd ~ || exit
    if [[ -z "$1" ]]; then
        read -p "Type the Node.js version you want to install (14, 13, 12, 11, 10), followed by [ENTER]: " NODE_VERSION
    fi

    curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | sudo -E bash -
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
check_CPU() {
    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq ]; then
        CPU="| CPU Freq="$(expr "$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)" / 1000)" MHz "
    else
        CPU=''
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
        lxpanelctl restart
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
    INSTALLER_DEPS="$@"
    for i in "${INSTALLER_DEPS[@]}"; do
        echo -n ":::    Checking for $i..."
        package_check ${i} >/dev/null
        if ! [ $? -eq 0 ]; then
            echo -n " Not found! Installing...\n"
            sudo apt install -y "$i"
            echo " done!"
        else
            echo " already installed!"
        fi
    done
}

#
# Check last time 'apt-get update' and run it if has passed 7 days
#
check_update() {
    NOW=$(date -d "2016-09-10 11:14:32" +%s)
    UPDATE=$(stat -c %y /var/cache/apt/ | awk '{print $1,$2}' | date -d $? +%s)
    # UPDATE=$(stat -c %y /var/cache/apt/ | awk '{print $1,$2}' | date -d $? +%s)
    # passed days
    RESULT=$(((UPDATE - NOW) / 86400))
    if [ $RESULT -ge 7 ]; then
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
    local IS_UP_TO_DATE=$(git diff --name-only origin/master)
    if [[ "$IS_UP_TO_DATE" ]]; then
        echo -e "\n New version available!\n\n · Installing updates...\n"
        git fetch --all
        git reset --hard origin/master
        git pull origin master
        echo
        echo -e "PiKISS is up to date!. \n\nYou need to run the program again.\n"
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

getRaspberryPiNumberModel() {
    echo $(cat /proc/device-tree/model | awk '{print $3}')
}

#
# Install SDL2 from RetroPie
# NOTE: It has a bug with ScummVM
#
install_sdl2() {
    echo "Installing SDL2 from RetroPie, please wait..."
    mkdir -p "$HOME"/sc && cd "$_" || exit
    git clone https://github.com/RetroPie/RetroPie-Setup.git
    cd RetroPie-Setup/ || exit
    sudo ./retropie_packages.sh sdl2 install_bin
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
        makeWithAllCores
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
    tar zxvf SDL2_image-2.0.5.tar.gz && cd SDL2_image-2.0.5
    ./autogen.sh
    ./configure --prefix=/usr
    makeWithAllCores
    sudo make install
}

compile_sdl2_mixer() {
    clear && echo "Compiling SDL2_mixer, please wait..."
    cd "$HOME"/sc || exit
    wget https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-2.0.4.tar.gz
    tar zxvf SDL2_mixer-2.0.4.tar.gz && cd SDL2_mixer-2.0.4
    ./autogen.sh
    ./configure --prefix=/usr
    makeWithAllCores
    sudo make install
}

compile_sdl2_ttf() {
    clear && echo "Compiling SDL2_ttf, please wait..."
    cd "$HOME"/sc || exit
    wget https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-2.0.15.tar.gz
    tar zxvf SDL2_ttf-2.0.15.tar.gz && cd SDL2_ttf-2.0.15
    ./autogen.sh
    ./configure --prefix=/usr
    makeWithAllCores
    sudo make install
}

compile_sdl2_net() {
    clear && echo "Compiling SDL2_net, please wait..."
    cd "$HOME"/sc || exit
    wget https://www.libsdl.org/projects/SDL_net/release/SDL2_net-2.0.1.tar.gz
    tar zxvf SDL2_net-2.0.1.tar.gz && cd SDL2_net-2.0.1
    ./autogen.sh
    ./configure --prefix=/usr
    makeWithAllCores
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
# Add php7 repository
#
add_php7_repository() {
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

#
# Message use the MagicAirCopy® technology
#
message_magic_air_copy() {
    local MESSAGES_LIST
    MESSAGES_LIST=(
        "You didn't lend it out?"
        "Really?!"
        "What a mess!"
        "You sure the game is here?"
        "You sure you bought this game?"
        "Clean up your room next time"
        "Dust in the wind, and dust in your room"
        "This is a dirty job"
        "I quit!"
        "Why do you punished me doing this?"
        "You won't believe what 'other' thing I've found under your bed"
    )
    size=${#MESSAGES_LIST[@]}
    index=$(($RANDOM % $size))
    clear
    echo -e "\nLooking for the copy at your house...\n" && sleep 4
    echo -e "${MESSAGES_LIST[$index]}\n" && sleep 3
    echo -e "Found it!...\n" && sleep 2
    echo "I'm moving the data files FROM YOUR original copy to destination directory using the technology MagicAirCopy® (｀-´)⊃━☆ﾟ.*･｡ﾟ"
}

#
# Extract row from a file
#
extract_url_from_file() {
    local tmp_file=/tmp/shareware
    wget -qO "$tmp_file" bit.ly/34u8zvZ
    sed "$1q;d" "$tmp_file"
    rm "$tmp_file"
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
    echo -e "\nSee you soon!. You can find me here (CTRL + Click):\n\n · Blog: https://misapuntesde.com\n · Twitter: https://twitter.com/ulysess10\n · Discord Server (Pi Labs): https://discord.gg/Y7WFeC5\n · Mail: ulysess@gmail.com\n\n · Wanna be my Patron?: https://www.patreon.com/cerrejon?fan_landing=true"
    exit
}

#
# Compile with all cores
#
makeWithAllCores() {
    if [ -n "$1" ]; then
        echo -e "$1"
    fi
    make -j"$(nproc)"
}

#
# Uninstall PiKISS
#
uninstall_pikiss() {
    clear
    echo -e "\nUninstalling..."
    rm -f "$HOME"/.local/share/applications/pikiss.desktop
    rm -rf "${PWD}"
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
        sudo sed -i "$i gpu_mem=$GPU_SIZE" "$BOOTCFG_PATH"
    fi
}