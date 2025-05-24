#!/bin/bash -ex
#
# Description : Git Server
# Author      : Jose Cerrejon Gonzalez (ulysess@gmail_dot._com)
# Version     : 1.2 (6/Dec/24)
# Tested on   : Raspberry Pi 5
#
# HELP        · https://www.instructables.com/id/GitPi-A-Private-Git-Server-on-Raspberry-Pi/all/?lang=es
# 			  · https://www.pihomeserver.fr/en/2015/05/05/utiliser-le-raspberry-pi-comme-serveur-git-prive/
#
# shellcheck source=../helper.sh
. ./scripts/helper.sh || . ../helper.sh || wget -q 'https://github.com/jmcerrejon/PiKISS/raw/master/scripts/helper.sh'
clear
check_board || { echo "Missing file helper.sh. I've tried to download it for you. Try to run the script again." && exit 1; }

IP=$(get_ip)
INPUT=/tmp/option.sh.$$

remove_docker_git_server() {
    if [ "$(docker ps -a -q -f name=gitlab)" ]; then
        read -p "A container named 'gitlab' already exists. Do you want to remove it and prune the container and image? (y/n): " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            docker rm -f gitlab
            docker system prune -f --volumes
        else
            echo "Please remove or rename the existing 'gitlab' container and try again."
        fi
        exit_message
    fi
}

install_git_server_docker_image() {
    clear
    if ! command -v docker &>/dev/null; then
        echo "Docker is not installed. Please install Docker and try again."
        exit_message
    fi

    remove_docker_git_server

    echo "Installing GitLab Docker Image fron https://github.com/ravermeister/gitlab, please wait..."
    docker pull ravermeister/gitlab
    docker run -d \
        --hostname gitlab.raspberry.com \
        -p 443:443 -p 80:80 -p 222:222 \
        --name gitlab \
        --restart always \
        -v /srv/gitlab/config:/etc/gitlab:Z \
        -v /srv/gitlab/logs:/var/log/gitlab:Z \
        -v /srv/gitlab/data:/var/opt/gitlab:Z \
        ravermeister/gitlab
    echo "GitLab is running on http://$IP."
}

set_git_bare() {
    clear
    trap 'rm $INPUT; exit' SIGHUP SIGINT SIGTERM

    read -p "This make a Git Server on $HOME/gitserver.git/repository_name. Press [ENTER] to continue or [CTRL]+C to Quit."
    dialog --inputbox "Enter your repo name:" 8 40 2>"${INPUT}"
    mkdir -p "$HOME/gitserver.git/$(<"${INPUT}")" && cd "$_" || exit
    git init --bare

    echo -e "Now execute on your local git repository: git remote add pi pi@$IP:$HOME/gitserver.git/$(<"${INPUT}")\nWhen you want to submit the changes: git push pi {master,main}\nNOTE:It doesn't upload the files, only the changes."
    read -p "Press [ENTER] to continue..."
}

while true; do
    dialog --clear --title "Git Server Setup" \
        --menu "Choose an option:" 10 50 4 \
        1 "Install GitLab Docker Image" \
        2 "Set Up Git Bare Repository" \
        3 "Exit" 2>"${INPUT}"

    menuitem=$(<"${INPUT}")

    case $menuitem in
    1) install_git_server_docker_image && break ;;
    2) set_git_bare && break ;;
    3) break ;;
    esac
done

rm -f "${INPUT}"
exit_message
