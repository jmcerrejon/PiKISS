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
compile_box86() {
    local PI_VERSION_NUMBER
    local SOURCE_PATH

    PI_VERSION_NUMBER=$(getRaspberryPiNumberModel)
    SOURCE_PATH="https://github.com/ptitSeb/box86.git"

    install_packages_if_missing cmake
    cd
    if [[ ! -d "$HOME"/box86 ]]; then
        git clone "$SOURCE_PATH" box86 && cd "$_"
    else
        echo -e "\nUpdating the repo if proceed,...\n"
        cd ~/box86 && git pull
        rm -rf build
    fi
    mkdir -p build && cd "$_"
    cmake .. -DRPI${PI_VERSION_NUMBER}=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo
    make_with_all_cores
    sudo make install
    echo -e "\nBox86 compiled and has been installed.\n"
}

install_box86() {
    local BINARY_BOX86_URL
    BINARY_BOX86_URL="https://misapuntesde.com/rpi_share/pilabs/box86.tar.gz"

    if [[ -f /usr/local/bin/box86 ]]; then
        echo
        read -p "Box86 already installed. Do you want to update it (Y/n)? " response
        if [[ $response =~ [Nn] ]]; then
            return 0
        fi

        compile_box86
    fi

    echo -e "\n\nInstalling Box86..."
    download_and_extract "$BINARY_BOX86_URL" "$HOME"
    cd "$HOME"/box86/build
    sudo make install
    echo -e "\nBox86 has been installed.\n"
}

installGL4ES() {
    local BINARY_URL
    BINARY_URL="https://misapuntesde.com/rpi_share/pilabs/gl4es.tar.gz"

    if [ -d ~/gl4es ]; then
        echo -e "~/gl4es is already installed, skipping..."
        return 0
    fi

    echo -e "\n\nInstalling GL4ES lib...\n"
    download_and_extract "$BINARY_URL" "$HOME"
}

installMesa() {
    local BINARY_URL
    BINARY_URL="https://misapuntesde.com/rpi_share/pilabs/mesa.tar.gz"

    if [ -d ~/mesa ]; then
        echo -e "~/mesa is already installed, skipping..."
        return 0
    fi

    echo -e "\n\nInstalling Mesa lib...\n"
    download_and_extract "$BINARY_URL" "$HOME"
}

installMonolibs() {
    local BINARY_URL
    BINARY_URL="https://misapuntesde.com/rpi_share/pilabs/monolibs.tar.gz"

    if [ ! -d /home/pi/monolibs ]; then
        wget -O /home/pi/monolibs.tar.gz "$BINARY_URL"
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
install_packages_if_missing() {
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
        cd "$DESTINATION_DIR"
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
        cd "$DESTINATION_DIR"
        ${COMMAND} "$FILE_NAME" -c "$DATA_URL"
    elif [[ -e "$DATA_URL" ]]; then
        # TODO Refactor. We don't need to copy if it's a local file or directory
        echo -e "\nCopying from local storage...\n"
        cp -ur "$DATA_URL" "$DESTINATION_DIR"
    fi
}

set_download_manager() {
    if [[ $1 == 'aria2c'  ]]; then
        install_packages_if_missing aria2
        echo "aria2c -x16 --max-tries=0 --check-certificate=false --file-allocation=none -o"
    fi

    echo "wget -q --show-progress -O"
}

#
# Download a .deb and install it
# $1 url
#
download_and_install() {
    local FILE
    FILE=$(get_file_name_from_path "$1")

    download_file "$1" "$2"
    echo -e "\nInstalling..." && sudo dpkg --force-all -i /tmp/"$FILE"
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
    tar zxvf SDL2_image-2.0.5.tar.gz && cd SDL2_image-2.0.5
    ./autogen.sh
    ./configure --prefix=/usr
    make_with_all_cores
    sudo make install
}

compile_sdl2_mixer() {
    clear && echo "Compiling SDL2_mixer, please wait..."
    cd "$HOME"/sc || exit
    wget https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-2.0.4.tar.gz
    tar zxvf SDL2_mixer-2.0.4.tar.gz && cd SDL2_mixer-2.0.4
    ./autogen.sh
    ./configure --prefix=/usr
    make_with_all_cores
    sudo make install
}

compile_sdl2_ttf() {
    clear && echo "Compiling SDL2_ttf, please wait..."
    cd "$HOME"/sc || exit
    wget https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-2.0.15.tar.gz
    tar zxvf SDL2_ttf-2.0.15.tar.gz && cd SDL2_ttf-2.0.15
    ./autogen.sh
    ./configure --prefix=/usr
    make_with_all_cores
    sudo make install
}

compile_sdl2_net() {
    clear && echo "Compiling SDL2_net, please wait..."
    cd "$HOME"/sc || exit
    wget https://www.libsdl.org/projects/SDL_net/release/SDL2_net-2.0.1.tar.gz
    tar zxvf SDL2_net-2.0.1.tar.gz && cd SDL2_net-2.0.1
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
    local SIZE
    local INDEX
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
        "It stinks here!"
        "Take a bucket of water and clean up a little"
        "Shouldn't you be studying?"
        "Why don't you go look for it?"
        "I find it, what do you give me in return?"
        "Did you fart or does your room smell like this always?"
        "Oh my gosh!, Oh my gosh!, Oh my gosh!"
        "Are you really going to be watching while I look for it?"
        "I foun!... Ah, it's not that"
    )
    SIZE=${#MESSAGES_LIST[@]}
    INDEX=$(("$RANDOM" % "$SIZE"))

    clear
    echo -e "\nLooking for the copy at your house...\n" && sleep 3
    echo -e "${MESSAGES_LIST[$INDEX]}\n" && sleep 2

    if [ -n "$1" ] && ! is_URL_broken "$1"; then
        echo -e "Found it!...\n"
        echo "I'm moving the data files FROM YOUR original copy to destination directory using the technology MagicAirCopy® (｀-´)⊃━☆ﾟ.*･｡ﾟ"
        true
    else
        echo -e "Data files not found. Anyway, clean your room and remember: Winners don't use drugs..."
        false
    fi
}

#
# Extract row from a file
#
extract_path_from_file() {
    local MAGIC_FILE_PATH
    # TODO Get in the next the path for piKISS
    MAGIC_FILE_PATH="${HOME}/piKiss/res/magic-air-copy-pikiss.txt"

    if [[ ! -f $MAGIC_FILE_PATH ]]; then
        echo -e "\nFile $MAGIC_FILE_PATH not found. You know what to do."
        exit 1
    fi

    grep "$1=" "$MAGIC_FILE_PATH" | awk -F "$1=" '{print $2}'
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
    echo -e "\nSee you soon.\nPiKISS is a software maintained by Jose Cerrejon.\nYou can find me here (CTRL + Click):\n\n · PiKISS Repository: https://github.com/jmcerrejon/PiKISS\n · Blog: https://misapuntesde.com\n · Twitter: https://twitter.com/ulysess10\n · Discord Server (Pi Labs): https://discord.gg/Y7WFeC5\n · Mail: ulysess@gmail.com\n\n · Wanna be my Patron?: https://www.patreon.com/cerrejon?fan_landing=true"
    exit
}

#
# Compile with all cores
#
make_with_all_cores() {
    if [ -n "$1" ]; then
        echo -e "$1"
    fi
    make -j"$(nproc)"
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
    rm -f  "$PIKISS_SHORTCUT_PATH"
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
        sudo sed -i "$i gpu_mem=$GPU_SIZE" "$BOOTCFG_PATH"
    fi
}

#
# Ket two key string from the keyboard layout
#
get_keyboard_layout() {
    echo "$(setxkbmap -query | grep layout | awk -F: '{print $2}' | sed 's/^ *//g')"
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
        echo "PATH=$PATH:$HOME/.cargo/bin" >> ~/.bashrc
    fi
}

#
# Return boolean if url is not online
#
is_URL_broken() {
    local URL

    if ! isPackageInstalled httpie; then
        sudo apt-get install -qq httpie < /dev/null > /dev/null
    fi
    # URL=$(curl -I "$1" 2>&1 | awk '/HTTP\// {print $2}') | Method 1
    URL=$(http --verify=no -h "$1" | awk 'NR==1' | awk '{print $2}')

    if [ "$URL" != 200 ]; then
        true
    else
        false
    fi
}

install_script_message() {
    echo -e "PiKISS is going to install this software for you ;)\n"
}

#
# Return true if is a URL
#
is_URL() {
    if [[ $1 == "http://" ]] || [[ $1 == "https://" ]]; then
        true
    else
        false
    fi
}