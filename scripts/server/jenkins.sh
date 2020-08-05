#!/bin/bash
#
# Description : Jenkins CI
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.0 (05/Aug/20)
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

PACKAGES=(openjdk-11-jre)
IP=$(get_ip)

remove_files() {
	sudo rm -rf /run/jenkins /etc/default/jenkins /var/lib/jenkins /var/log/jenkins /var/cache/jenkins \
	/run/systemd/generator.late/graphical.target.wants/jenkins.service \
	/run/systemd/generator.late/multi-user.target.wants/jenkins.service \
	/run/systemd/generator.late/jenkins.service \
	/tmp/hsperfdata_jenkins /etc/rc5.d/S01jenkins /etc/rc6.d/K01jenkins \
	/etc/rc2.d/S01jenkins /etc/rc1.d/K01jenkins /etc/apt/sources.list.d/jenkins.list \
	/etc/rc0.d/K01jenkins /etc/init.d/jenkins /etc/rc4.d/S01jenkins /etc/rc3.d/S01jenkins \
	/etc/logrotate.d/jenkins
}

uninstall() {
	read -p "Do you want to uninstall Jenkins (y/N)? " response
	if [[ $response =~ [Yy] ]]; then
		sudo apt remove -y jenkins openjdk-11-jre daemon
		remove_files
		if [[ -e "$INSTALL_DIR"/arx ]]; then
			echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
			exit_message
		fi
		echo -e "\nSuccessfully uninstalled."
		exit_message
	fi
	exit_message
}

if [[ -d /usr/share/jenkins ]]; then
	echo -e "Jenkins already installed.\n"
	uninstall
	exit 1
fi

install_dependencies() {
	sudo apt-get update
	installPackagesIfMissing "${PACKAGES[@]}"
	java --version
	sleep 3
	echo -e "\nAdding Repository..."
	sudo wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
	echo "deb https://pkg.jenkins.io/debian binary/" | sudo tee -a /etc/apt/sources.list.d/jenkins.list >/dev/null
	sudo apt -qq update
}

post_install() {
	if [[ ! -f /var/lib/jenkins/secrets/initialAdminPassword ]]; then
		return 0
	fi
	local KEY
	KEY="$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)"
	echo -e "\nYour jenkins password is: ${KEY}\n"
	echo "Done!. Now you can browser to http://${IP}:8080"
}

install() {
	install_dependencies
	echo -e "\nInstalling Jenkins..."
	sudo apt install -y daemon jenkins
	# systemctl status jenkins.service
	post_install
	exit_message
}

echo "Install Jenkins"
echo "==============="
echo
echo " · Latest version."
echo " · Install Java JRE 11."
echo " · 100.5 MB aprox. total space occupied."
echo
read -p "Press [Enter] to continue..."

install
