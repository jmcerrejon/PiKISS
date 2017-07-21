#!/bin/bash
#
# Description : Helpers functions
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
#
# Directive to disable the warning:
# shellcheck disable=SC2034
#
get_ip() {
	local IP
	IP=$(hostname -I | awk '{print $1}')
	echo "$IP"
}

get_distro_name() {
	local DISTRO
	DISTRO=$(lsb_release -si)
	echo "$DISTRO"
}

download_and_extract(){
	wget $1 && extract "$(basename $_)" ; rm "$(basename $_)"
}

is_pkg_installed() {
	dpkg -s $1 &> /dev/null

	if [ $? -eq 0 ]; then
	    echo "Package  is installed!"
	else
	    echo "Package  is NOT installed!"
	fi
}

file_backup() {
	if [ -f $1 ]; then
		if [ -w "$(dirname $1)" ]; then
			echo "escribir como user"
	 		cp $1{,.bak}
		else
			echo "escribir como root"
			sudo cp $1{,.bak}
		fi
	fi
}

install_node(){
	cd ~ || exit
	curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
	sudo apt install -y nodejs build-essential libssl-dev
	node -v
}

check_board() {
	if [[ $(cat /proc/cpuinfo | grep 'ODROIDC') ]]; then
		MODEL="ODROID-C1"
	elif [[ $(cat /proc/cpuinfo | grep 'BCM2708\|BCM2709\|BCM2835') ]]; then
		MODEL="Raspberry Pi"
	elif [ "$(uname -n)" = "debian" ]; then
		MODEL="Debian"
	else
		MODEL="UNKNOWN"
		dialog --title '[ WARNING! ]' --msgbox "Board or Operating System not compatible.\nUse at your own risk." 6 45
	fi
}

SDL_fix_Rpi() {
	echo "Applying fix to SDL on Raspberry Pi 2, please wait..."
	if [[ $(cat /proc/cpuinfo | grep 'BCM2709') && $(stat -c %y /usr/lib/arm-linux-gnueabihf/libSDL-1.2.so.0.11.4 | grep '2012') ]]; then
		wget -P /tmp http://malus.exotica.org.uk/~buzz/pi/sdl/sdl1/deb/rpi1/libsdl1.2debian_1.2.15-8rpi_armhf.deb
		sudo dpkg -i /tmp/libsdl1.2debian_1.2.15-8rpi_armhf.deb
		sudo rm /tmp/libsdl1.2debian_1.2.15-8rpi_armhf.deb
	fi
}

check_temperature() {
 if [ -f /opt/vc/bin/vcgencmd ]; then
 	TEMPC="| $(/opt/vc/bin/vcgencmd measure_temp | awk '{print $1"º"}') "
 elif [ -f /sys/devices/virtual/thermal/thermal_zone0/temp ]; then
 	TEMPC="| TEMP: $(cat /sys/devices/virtual/thermal/thermal_zone0/temp | cut -c1-2 | awk '{print $1"º"}') "
 else
 	TEMPC=''
 fi
}

check_CPU() {
 if [ -f /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq ]; then
 	CPU="| CPU Freq="`expr "$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)" / 1000`" MHz "
 else
 	CPU=''
 fi
}

check_internet_available() {
# Make sure we have internet conection
if [ ! "$NOINTERNETCHECK" = 1 ]; then
	PINGOUTPUT=$(ping -c 1 8.8.8.8 > /dev/null && echo 'true')
	if [ ! "$PINGOUTPUT" = true ]; then
		echo "Internet connection required. Check your network."; exit 1
	fi
fi
}

show_dialog() {
	local h=${1-10}			# box height default 10
	local w=${2-41} 		# box width default 41
	local t=${3-Output} 	# box title

	while true
do

	dialog --clear   \
		--title		"[ M A I N - M E N U ]" \
		--menu 		"You can use the UP/DOWN arrow keys, the first letter of the choice as a hot key, or the number keys 1-4 to choose an option." ${h} ${w} \
		"$(<$OUTPUT)"
		Exit 		"Exit to the shell" 2> "$(<$INPUT)"

	menuitem=$(<"${INPUT}")

	case $menuitem in
		Tweaks)	    	smTweaks ;;
		Games) 	    	smGames ;;
	        Emula)	    	smEmulators ;;
		Info)	    	smInfo ;;
		Multimedia) 	smMultimedia ;;
		Configure)  	smConfigure ;;
		Internet)   	smInternet ;;
		Server)     	smServer ;;
		Others)     	smOthers ;;
		Exit) 	    	echo -e "\nThanks for visiting http://misapuntesde.com" && exit ;;
1)
    echo -e "\nCancel pressed." && exit;;
  255)
    echo -e "\nESC pressed." && exit;;
	esac
done
}

mkDesktopEntry() {
	# Add lxterminal -t "PiKISS" --geometry=150x25 --working-directory=/home/pi/PiKISS -e './piKiss.sh'
	if [[ ! -e /usr/share/applications/pikiss.desktop ]]; then
		sudo sh -c 'echo "[Desktop Entry]\nName=PiKISS\nComment=A bunch of scripts with menu to make your life easier\nExec='$PWD'/PiKISS/piKiss.sh\nIcon=terminal\nTerminal=true\nType=Application\nCategories=ConsoleOnly;Utility;System;\nPath='$PWD'/" > /usr/share/applications/pikiss.desktop'
		# if [[ -e ./piKiss.sh ]]; then
		# 	sed -i -e 's/mkDesktopEntry/#mkDesktopEntry/ig' ./piKiss.sh
		# fi
	fi
}

validate_url() {
    if [[ `wget -S --spider $1 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then echo "true"; fi
}

install_joypad() {
	echo -e "\nDo you want to install joystick/pad packages?"
	read -p "Agree (y/n)? " option
	case "$option" in
		y*) dpkg -l | grep ^"ii  joystick" > /dev/null || sudo apt-get install -y joystick jstest-gtk;
		jscal /dev/input/js0;
		# Check if X is running
		if ! xset q &>/dev/null; then
			jstest /dev/input/js0;
		else
			jstest-gtk;
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
		echo -n ":::    Checking for $i..."
		package_check ${i} > /dev/null
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
	RESULT=$(( (UPDATE - NOW) / 86400))
	if [ $RESULT -ge 7 ]; then
	    sudo apt-get update
	fi
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
# Compile SDL2
#
compile_sdl2() {
	if [ ! -e /usr/include/SDL2 ]; then
		echo "Compiling SDL2 2.0.4, please wait about 5 minutes..."
		mkdir -p $HOME/sc && cd $HOME/sc || exit
		wget https://www.libsdl.org/release/SDL2-2.0.4.zip
		unzip SDL2-2.0.4.zip && cd SDL2-2.0.4 || exit
		./configure --host=armv7l-raspberry-linux-gnueabihf --prefix=/usr --disable-pulseaudio --disable-esd --disable-video-mir --disable-video-wayland --disable-video-x11 --disable-video-opengl
		make -j4
		sudo make install
		echo "Done!"
	else
		echo -e "\n· SDL2 already installed.\n"
	fi
}

#
# Install GCC 6 on Jessie
#
ask_gcc6() {
	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' gcc-6|grep "install ok installed")
	echo "Checking for somelib: $PKG_OK"
	if [ "" == "$PKG_OK" ]; then
		dialog --title     "[ GCC 6 for Debian Jessie ]" \
			--yes-label "Yes. Let's crack on!" \
			--no-label  "Nope" \
			--yesno     "Caution: You could broke your Raspbian distribution. Are you sure you want to install it?. This process takes time." 7 80

		retval=$?

		case $retval in
			0)   install_gcc6 ;;
			1)   exit ;;
			255) exit ;;
		esac
	fi
}

install_gcc6() {
	sudo cp /etc/apt/sources.list{,.bak}
	sudo sed -i 's/jessie/stretch/g' /etc/apt/sources.list
	sudo apt-get update
	sudo apt install -y gcc-6 g++-6
	sudo sed -i 's/stretch/jessie/g' /etc/apt/sources.list
	sudo apt-get update
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
add_php7_repository(){
	sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
	sudo sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
	sudo apt-get update
}

#
# Extract all kind of compressed files
#
extract () {
  if [ -f $1 ] ; then
      case $1 in
          *.tar.bz2 | *.tbz2) tar xvjf $1   ;;
          *.tar.gz | *.tgz)   tar xvzf $1   ;;
          *.bz2)              tar jxf $1    ;;
          *.rar)              unrar x $1    ;;
          *.gz)               gunzip $1     ;;
          *.tar)              tar xvf $1    ;;
          *.zip)              unzip $1      ;;
          *.Z)                uncompress $1 ;;
          *.7z)               7z x $1       ;;
          *.exe)              cabextract $1 ;;
          *)                  echo "'$1': unrecognized file compression" ;;
      esac
  else
      echo "'$1' is not a valid file"
  fi
}