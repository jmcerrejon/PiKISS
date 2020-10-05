#!/bin/bash
#
# Description : Jenkins CI
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.0.2 (05/Oct/20)
#
. ../helper.sh || . ./scripts/helper.sh || . ./helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

PACKAGES=(openjdk-11-jre xclip)
IP=$(get_ip)
URL="http://${IP}:8080"

runme() {
    echo
    read -p "Do you want to open the web browser with url $URL (Y/n)? " response
    if [[ $response =~ [Nn] ]]; then
        return 0
    fi
    chromium-browser "$URL" &>/dev/null
}

# TODO If I remove some of the next files, we can't install it again. Refactor it in the next release.
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
        sudo apt -y autoremove && sudo apt remove -y jenkins openjdk-11-jre daemon xclip
        # remove_files # TODO Commented (see above)
        if [[ -e "$INSTALL_DIR"/arx ]]; then
            echo -e "I hate when this happens. I could not find the directory, Try to uninstall manually. Apologies."
            exit_message
        fi
        echo -e "\nSuccessfully uninstalled."
        exit_message
    fi
    runme
}

if [[ -d /usr/share/jenkins ]]; then
    echo -e "Jenkins already installed.\n"
    uninstall
    exit 1
fi

install_dependencies() {
    sudo apt-get update
    install_packages_if_missing "${PACKAGES[@]}"
    java --version
    sleep 3
    if [[ ! -f /etc/apt/sources.list.d/jenkins.list ]]; then
        echo -e "\nAdding Repository..."
        sudo wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
        echo "deb https://pkg.jenkins.io/debian binary/" | sudo tee -a /etc/apt/sources.list.d/jenkins.list >/dev/null
    fi
    sudo apt -qq update
}

post_install() {
    clear
    sleep 3
    local KEY
    if sudo test ! -f /var/lib/jenkins/secrets/initialAdminPassword; then
        echo -e "\n/var/lib/jenkins/secrets/initialAdminPassword not found. Try to reinstall the app again."
        return 0
    fi
    KEY="$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)"
    echo -e "\nYour jenkins password is: ${KEY}\n"
    read -p "Do you want to copy the password to the clipboard (y/N)? " response
    if [[ $response =~ [Yy] ]]; then
        echo "$KEY" | xclip -selection c
        echo -e "\nPassword copied to clipboard!."
    fi
    echo -e "\nDone!. Now you can browser to $URL"
    runme
}

install() {
    install_dependencies
    echo -e "\nInstalling Jenkins..."
    sudo apt install -y daemon jenkins
    post_install
}

echo "Install Jenkins"
echo "==============="
echo
echo " · Latest version."
echo " · Install Java JRE 11."
echo " · ~100.5 MB total space occupied."
echo
read -p "Press [Enter] to continue..."
echo

install
exit_message