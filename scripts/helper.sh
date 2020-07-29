#!/bin/bash
#
# Description : Helpers functions
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
#
# Directive to disable the warning:
# shellcheck disable=SC2034
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
	local URL_PATH='https://www.dropbox.com/s/eeqip6lkegljmrl/box86.tar.gz?dl=0'
	download_and_extract "$URL_PATH" "$HOME"
}

installGL4ES() {
	if [ -d ~/gl4es ]; then
		echo -e "~/gl4es is already installed, skipping..."
		return 0
	fi
	echo -e "\n\nInstalling GL4ES lib...\n"
	local URL_PATH='https://www.dropbox.com/s/ed2z5su72115bc7/gl4es.tar.gz?dl=0'
	download_and_extract "$URL_PATH" "$HOME"
}

installMesa() {
	if [ -d ~/mesa ]; then
		echo -e "~/mesa is already installed, skipping..."
		return 0
	fi
	echo -e "\n\nInstalling Mesa lib...\n"
	local URL_PATH='https://www.dropbox.com/s/or0bre2pt4sc1i3/mesa.tar.gz?dl=0'
	download_and_extract "$URL_PATH" "$HOME"
}

installMonolibs() {
	local URL_PATH='https://www.dropbox.com/s/u4dmwnb88sk0la7/monolibs.tar.gz?dl=0'
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
	for PACKAGE in "$1"; do
		dpkg -s ${PACKAGE} &>/dev/null

		if [ "$?" -eq 1 ]; then
			MUST_INSTALL=true
			break
		fi
	done

	if [ ! "$MUST_INSTALL" ]; then
		return 0
	fi

	echo -e "\nInstalling dependencies...\n"
	sudo apt install -y ${PACKAGES[@]}
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
# Download a file and extract it
# $1 url
# $2 destination directory
#
download_and_extract() {
	if [ ! -d $2 ]; then
		echo "ERROR: Missing 2nd argument (destination directory) from helper.sh > download_and_extract."
		read -p "Press [ENTER] to exit."
		exit 1
	fi
	local SUFFIX=?dl=0
	local FILE=$(basename $1 | sed -e "s/$SUFFIX$//")
	echo -e "\nDownloading...\n"
	wget -q --show-progress -O "$2"/"$FILE" -c "$1"
	echo -e "\nExtracting..."
	cd "$2" && extract "$FILE"
	if [ -e $2/$FILE ]; then
		rm -f "$2"/"$FILE"
	fi
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
	if [ -f "$1 "]; then
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
	mkdir -p $HOME/sc && cd $HOME/sc || exit
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
		mkdir -p $HOME/sc && cd $HOME/sc || exit
		wget https://www.libsdl.org/release/SDL2-2.0.10.zip
		unzip SDL2-2.0.10.zip && cd SDL2-2.0.10 || exit
		./autogen.sh
		./configure --disable-pulseaudio --disable-esd --disable-video-wayland --disable-video-opengl --host=arm-raspberry-linux-gnueabihf --prefix=/usr
		make -j"$(getconf _NPROCESSORS_ONLN)"
		sudo make install
		echo "Done!"
	else
		echo -e "\n· SDL2 already installed.\n"
	fi
}

compile_sdl2_image() {
	clear && echo "Compiling SDL2_image, please wait..."
	cd $HOME/sc || exit
	wget https://www.libsdl.org/projects/SDL_image/release/SDL2_image-2.0.5.tar.gz
	tar zxvf SDL2_image-2.0.5.tar.gz && cd SDL2_image-2.0.5
	./autogen.sh
	./configure --prefix=/usr
	make -j"$(getconf _NPROCESSORS_ONLN)"
	sudo make install
}

compile_sdl2_mixer() {
	clear && echo "Compiling SDL2_mixer, please wait..."
	cd $HOME/sc || exit
	wget https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-2.0.4.tar.gz
	tar zxvf SDL2_mixer-2.0.4.tar.gz && cd SDL2_mixer-2.0.4
	./autogen.sh
	./configure --prefix=/usr
	make -j"$(getconf _NPROCESSORS_ONLN)"
	sudo make install
}

compile_sdl2_ttf() {
	clear && echo "Compiling SDL2_ttf, please wait..."
	cd $HOME/sc || exit
	wget https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-2.0.15.tar.gz
	tar zxvf SDL2_ttf-2.0.15.tar.gz && cd SDL2_ttf-2.0.15
	./autogen.sh
	./configure --prefix=/usr
	make -j"$(getconf _NPROCESSORS_ONLN)"
	sudo make install
}

compile_sdl2_net() {
	clear && echo "Compiling SDL2_net, please wait..."
	cd $HOME/sc || exit
	wget https://www.libsdl.org/projects/SDL_net/release/SDL2_net-2.0.1.tar.gz
	tar zxvf SDL2_net-2.0.1.tar.gz && cd SDL2_net-2.0.1
	./autogen.sh
	./configure --prefix=/usr
	make -j"$(getconf _NPROCESSORS_ONLN)"
	sudo make install
}

#
# Install GCC 6 on Jessie
#
ask_gcc6() {
	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' gcc-6 | grep "install ok installed")
	echo "Checking for somelib: $PKG_OK"
	if [ "" == "$PKG_OK" ]; then
		dialog --title "[ GCC 6 for Debian Jessie ]" \
			--yes-label "Yes. Let's crack on!" \
			--no-label "Nope" \
			--yesno "Caution: You could broke your Raspbian distribution. Are you sure you want to install it?. This process takes time." 7 80

		retval=$?

		case $retval in
		0) install_gcc6 ;;
		1) exit ;;
		255) exit ;;
		esac
	fi
}

install_gcc6() {
	sudo cp /etc/apt/sources.list{,.bak}
	sudo sed -i 's/jessie/stretch/g' /etc/apt/sources.list
	sudo apt-get -qq update
	sudo apt install -y gcc-6 g++-6
	sudo sed -i 's/stretch/jessie/g' /etc/apt/sources.list
	sudo apt-get -qq update
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
	clear
	echo -e "\nLooking for the copy at your house...\n" && sleep 4
	echo -e "You didn't lend it out?...\n" && sleep 3
	echo -e "Found it! (Clean up your room next time)...\n" && sleep 2
	echo "I'm moving the data files FROM YOUR original copy to destination directory using the technology MagicAirCopy® (｀-´)⊃━☆ﾟ.*･｡ﾟ"
}

#
# Extract row from a file
#
extract_url_from_file() {
	local tmp_file=/tmp/shareware
	wget -qO "$tmp_file" bit.ly/2X31Iou
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
		*.zip) unzip -qq "$1" ;;
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
