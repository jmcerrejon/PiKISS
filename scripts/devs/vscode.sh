#!/bin/bash
#
# Description : Code - OSS (VSCode fork) thanks to Jay Rodgers (headmelted)
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (15/Aug/20)
# Compatible  : Raspberry Pi 4 (tested)
#
# Help		  : https://wiki.residualvm.org/index.php/Building_ResidualVM
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

SOURCE_PATH="https://code.headmelted.com/installers/apt.sh"

runme() {
	echo
	if [ ! -f /usr/bin/code-oss ]; then
		echo -e "\nFile does not exist.\n· Something is wrong.\n· Try to install again."
		exit_message
	fi
	read -p "Press [ENTER] to run the app..."
	/usr/bin/code-oss
    sleep 10
	clear
	exit_message
}

remove_files() {
	rm -rf ~/.vscode-oss
}

uninstall() {
	read -p "Do you want to uninstall Code - OSS (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
        sudo apt remove -y code-oss
		remove_files
		if [[ -e "$INSTALL_DIR"/residualvm ]]; then
			echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
			exit_message
		fi
		echo -e "\nSuccessfully uninstalled."
		exit_message
	fi
	exit_message
}

if [[ -f /usr/bin/code-oss ]]; then
	echo -e "ResidualVM already installed.\n"
	uninstall
	exit 0
fi

install() {
	echo -e "\nInstalling, please wait..."
	wget "$SOURCE_PATH" -O /tmp/apt.sh
    chmod +x /tmp/apt.sh
    sudo /tmp/apt.sh
    rm /tmp/apt.sh
}

install
runme